{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NoFieldSelectors      #-}
{-# LANGUAGE OverloadedRecordDot   #-}

{-|
Module      : Control.Concurrent.Execute
Description : Concurrent execution with dependencies.
License     : BSD-3-Clause

Concurrent execution with dependencies. Types currently hard-coded for needs of
stack, but could be generalized easily.
-}

module Control.Concurrent.Execute
    ( ActionType (..)
    , ActionId (..)
    , ActionContext (..)
    , Action (..)
    , Concurrency (..)
    , runActions
    ) where

import           Control.Concurrent.STM ( check )
import           Stack.Prelude
import           Data.List ( sortBy )
import qualified Data.Set as Set

-- | Type representing exceptions thrown by functions exported by the
-- "Control.Concurrent.Execute" module.
data ExecuteException
  = InconsistentDependenciesBug
  deriving (Show, Typeable)

instance Exception ExecuteException where
  displayException InconsistentDependenciesBug = bugReport "[S-2816]"
    "Inconsistent dependencies were discovered while executing your build \
    \plan."

-- | Type representing types of Stack build actions.
data ActionType
  = ATBuild
    -- ^ Action for building a package's library and executables. If
    -- 'Stack.Types.Build.Task.allInOne' is 'True', then this will also build
    -- benchmarks and tests. It is 'False' when the library's benchmarks or
    -- test-suites have cyclic dependencies.
  | ATBuildFinal
    -- ^ Task for building the package's benchmarks and test-suites. Requires
    -- that the library was already built.
  | ATRunTests
    -- ^ Task for running the package's test-suites.
  | ATRunBenchmarks
    -- ^ Task for running the package's benchmarks.
  deriving (Show, Eq, Ord)

-- | Types representing the unique ids of Stack build actions.
data ActionId
  = ActionId !PackageIdentifier !ActionType
  deriving (Eq, Ord, Show)

-- | Type representing Stack build actions.
data Action = Action
  { actionId :: !ActionId
    -- ^ The action's unique id.
  , actionDeps :: !(Set ActionId)
    -- ^ Actions on which this action depends.
  , action :: !(ActionContext -> IO ())
    -- ^ The action's 'IO' action, given a context.
  , concurrency :: !Concurrency
    -- ^ Whether this action may be run concurrently with others.
  }

-- | Type representing permissions for actions to be run concurrently with
-- others.
data Concurrency
  = ConcurrencyAllowed
  | ConcurrencyDisallowed
  deriving Eq

data ActionContext = ActionContext
  { remaining :: !(Set ActionId)
    -- ^ Does not include the current action.
  , downstream :: [Action]
    -- ^ Actions which depend on the current action.
  , concurrency :: !Concurrency
    -- ^ Whether this action may be run concurrently with others.
  }

data ExecuteState = ExecuteState
  { actions    :: TVar [Action]
  , exceptions :: TVar [SomeException]
  , inAction   :: TVar (Set ActionId)
  , completed  :: TVar Int
  , keepGoing  :: Bool
  }

runActions ::
     Int -- ^ threads
  -> Bool -- ^ keep going after one task has failed
  -> [Action]
  -> (TVar Int -> TVar (Set ActionId) -> IO ()) -- ^ progress updated
  -> IO [SomeException]
runActions threads keepGoing actions withProgress = do
  es <- ExecuteState
    <$> newTVarIO (sortActions actions) -- esActions
    <*> newTVarIO [] -- esExceptions
    <*> newTVarIO Set.empty -- esInAction
    <*> newTVarIO 0 -- esCompleted
    <*> pure keepGoing -- esKeepGoing
  _ <- async $ withProgress es.completed es.inAction
  if threads <= 1
    then runActions' es
    else replicateConcurrently_ threads $ runActions' es
  readTVarIO es.exceptions

-- | Sort actions such that those that can't be run concurrently are at
-- the end.
sortActions :: [Action] -> [Action]
sortActions = sortBy (compareConcurrency `on` (.concurrency))
 where
  -- NOTE: Could derive Ord. However, I like to make this explicit so
  -- that changes to the datatype must consider how it's affecting
  -- this.
  compareConcurrency ConcurrencyAllowed ConcurrencyDisallowed = LT
  compareConcurrency ConcurrencyDisallowed ConcurrencyAllowed = GT
  compareConcurrency _ _ = EQ

runActions' :: ExecuteState -> IO ()
runActions' es = loop
 where
  loop :: IO ()
  loop = join $ atomically $ breakOnErrs $ withActions processActions

  breakOnErrs :: STM (IO ()) -> STM (IO ())
  breakOnErrs inner = do
    errs <- readTVar es.exceptions
    if null errs || es.keepGoing
      then inner
      else doNothing

  withActions :: ([Action] -> STM (IO ())) -> STM (IO ())
  withActions inner = do
    actions <- readTVar es.actions
    if null actions
      then doNothing
      else inner actions

  processActions :: [Action] -> STM (IO ())
  processActions actions = do
    inAction <- readTVar es.inAction
    case break (Set.null . (.actionDeps)) actions of
      (_, []) -> do
        check (Set.null inAction)
        unless es.keepGoing $
          modifyTVar es.exceptions (toException InconsistentDependenciesBug:)
        doNothing
      (xs, action:ys) -> processAction inAction (xs ++ ys) action

  processAction :: Set ActionId -> [Action] -> Action -> STM (IO ())
  processAction inAction otherActions action = do
    let concurrency = action.concurrency
    unless (concurrency == ConcurrencyAllowed) $
      check (Set.null inAction)
    let action' = action.actionId
        otherActions' = Set.fromList $ map (.actionId) otherActions
        remaining = Set.union otherActions' inAction
        downstream = downstreamActions action' otherActions
        actionContext = ActionContext
          { remaining
          , downstream
          , concurrency
          }
    writeTVar es.actions otherActions
    modifyTVar es.inAction (Set.insert action')
    pure $ do
      mask $ \restore -> do
        eres <- try $ restore $ action.action actionContext
        atomically $ do
          modifyTVar es.inAction (Set.delete action')
          modifyTVar es.completed (+1)
          case eres of
            Left err -> modifyTVar es.exceptions (err:)
            Right () -> modifyTVar es.actions $ map (dropDep action')
      loop

  -- | Filter a list of actions to include only those that depend on the given
  -- action.
  downstreamActions :: ActionId -> [Action] -> [Action]
  downstreamActions aid = filter (\a -> aid `Set.member` a.actionDeps)

  -- | Given two actions (the first specified by its id) yield an action
  -- equivalent to the second but excluding any dependency on the first action.
  dropDep :: ActionId -> Action -> Action
  dropDep action' action =
    action { actionDeps = Set.delete action' action.actionDeps }

  -- | @IO ()@ lifted into 'STM'.
  doNothing :: STM (IO ())
  doNothing = pure $ pure ()
