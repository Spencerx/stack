{- |
Integration-test helpers & fixtures for testing `stack repl`
-}
module StackTest.Repl
    ( Repl
    , ReplConnection (..)
    , nextPrompt
    , replCommand
    , replGetChar
    , replGetLine
    , stackRepl
    -- * Reexport
    , module StackTest
    ) where

import Control.Exception (SomeException, catch, displayException, finally)
import Control.Monad ((>=>), unless, when)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans (lift)
import Control.Monad.Trans.Reader
import Control.Monad.Trans.State qualified as State
import Data.Maybe (fromMaybe)
import Data.Foldable (toList)
import Data.Sequence as Seq (Seq(Empty), (|>), fromList)
import GHC.Stack (HasCallStack)
import System.Directory (removeFile)
import System.Environment (lookupEnv)
import System.Exit (ExitCode (..), exitFailure)
import System.IO
    ( BufferMode (NoBuffering, LineBuffering), Handle, IOMode (ReadMode)
    , hClose, hGetChar, hGetContents', hGetLine, hPutStrLn, hSetBuffering
    , openTempFile
    , withFile
    )
import System.Process
    ( CreateProcess (std_err, std_in, std_out)
    , StdStream (CreatePipe, UseHandle)
    , createProcess, proc, waitForProcess
    )

import StackTest

type Repl = ReaderT ReplConnection IO

data ReplConnection = ReplConnection
  { replStdin  :: Handle
  , replStdout :: Handle
  }

replCommand :: String -> Repl ()
replCommand cmd = do
  (ReplConnection replStdinHandle _) <- ask
  -- echo what we send to the test's stdout
  liftIO . putStrLn $ "____> " <> cmd
  liftIO $ hPutStrLn replStdinHandle cmd

replGetChar :: Repl Char
replGetChar = asks replStdout >>= liftIO . hGetChar

replGetLine :: Repl String
replGetLine = ask >>= liftIO . hGetLine . replStdout

nextPrompt :: Repl ()
nextPrompt = State.evalStateT poll Seq.Empty where
  poll = do
    c <- lift (asks replStdout) >>= liftIO . hGetChar
    State.modify (|> c)
    when (c == '\n') $ do
      State.get >>= liftIO . putStr . ("ghci> " ++) . toList
      State.put Seq.Empty
    buf <- State.get
    unless (buf == Seq.fromList "ghci> ")
      poll

runRepl
  :: HasCallStack
  => FilePath
  -> [String]
  -> Repl ()
  -> IO ExitCode
runRepl cmd args actions = do
  (stderrBufPath, stderrBufHandle) <- openTempStderrBufferFile
  hSetBuffering stderrBufHandle NoBuffering

  logInfo $ "Running: " ++ cmd ++ " " ++ unwords (map showProcessArgDebug args) ++ "\n\
            \         with stderr in " ++ stderrBufPath

  -- launch the GHCi subprocess, grab its FD handles and process handle
  (Just rStdin, Just rStdout, Nothing, ph) <-
    createProcess (proc cmd args)
      { std_in = CreatePipe
      , std_out = CreatePipe
      , std_err = UseHandle stderrBufHandle
      }
  hSetBuffering rStdin LineBuffering
  hSetBuffering rStdout NoBuffering

  -- run the test script which is to talk to the GHCi subprocess.
  runReaderT actions (ReplConnection rStdin rStdout)
    -- the nested actions script may fail in arbitrary ways; handle that here,
    -- attaching the subprocess stderr as relevant context
    `catch` \(e :: SomeException) -> do
      putStrLn "=============================="
      putStrLn "EXCEPTION in test: "
      putStrLn . quote $ displayException e
      putStrLn "------[ stderr of repl ]------"
      withFile stderrBufPath ReadMode $ hGetContents' >=> putStr . quote
      putStrLn "=============================="
    `finally` do
      hClose stderrBufHandle
      removeFile stderrBufPath

  -- once done with the test, signal EOF on stdin for clean termination of ghci
  hClose rStdin
  -- read out the exit-code
  waitForProcess ph

-- | Roll a bicycle, rather than just `import Path.IO (getTempDir, openTempFile)`,
-- because it's a hassle to use anything beyond base & boot libs here.
openTempStderrBufferFile :: IO (FilePath, Handle)
openTempStderrBufferFile = getTempDir >>= (`openTempFile` "err.log") where
  getTempDir | isWindows = fromMaybe "" <$> lookupEnv "TEMP"
             | otherwise = pure "/tmp"

-- | Testing helper to exercise `stack repl`.
stackRepl :: HasCallStack => [String] -> Repl () -> IO ()
stackRepl args action = do
  stackExe' <- stackExe
  ec <- runRepl stackExe' ("repl" : "--ghci-options=-ignore-dot-ghci" : args) action
  unless (ec == ExitSuccess) $ do
    putStrLn $ "repl exited with " <> show ec
    exitFailure

quote :: String -> String
quote = unlines . map ("> " <>) . lines
