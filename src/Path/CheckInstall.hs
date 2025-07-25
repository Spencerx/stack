{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

{-|
Module      : Path.CheckInstall
License     : BSD-3-Clause
-}

module Path.CheckInstall
  ( warnInstallSearchPathIssues
  ) where

import           Control.Monad.Extra ( (&&^), anyM )
import           Stack.Prelude
import           Stack.Types.Config ( HasConfig )
import qualified System.Directory as D
import qualified System.FilePath as FP

-- | Checks if the installed executable will be available on the user's PATH.
-- This doesn't use @envSearchPath menv@ because it includes paths only visible
-- when running in the Stack environment.
warnInstallSearchPathIssues ::
     HasConfig env
  => FilePath
  -> [String]
  -> RIO env ()
warnInstallSearchPathIssues destDir installed = do
  searchPath <- liftIO FP.getSearchPath
  destDirIsInPATH <- liftIO $
    anyM
      ( \dir ->     D.doesDirectoryExist dir
                &&^ fmap (FP.equalFilePath destDir) (D.canonicalizePath dir)
      )
      searchPath
  if destDirIsInPATH
    then forM_ installed $ \exe -> do
      (liftIO . D.findExecutable) exe >>= \case
        Just exePath -> do
          exeDir <-
            (liftIO . fmap FP.takeDirectory . D.canonicalizePath) exePath
          unless (exeDir `FP.equalFilePath` destDir) $
            prettyWarnL
              [ flow "The"
              , style File . fromString $ exe
              , flow "executable found on the PATH environment variable is"
              , style File . fromString $ exePath
              , flow "and not the version that was just installed."
              , flow "This means that"
              , style File . fromString $ exe
              , "calls on the command line will not use this version."
              ]
        Nothing ->
          prettyWarnL
            [ flow "Installation path"
            , style Dir . fromString $ destDir
            , flow "is on the PATH but the"
            , style File . fromString $ exe
            , flow "executable that was just installed could not be found on \
                   \the PATH."
            ]
    else
      prettyWarnL
        [ flow "Installation path "
        , style Dir . fromString $ destDir
        , "not found on the PATH environment variable."
        ]
