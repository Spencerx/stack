{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings   #-}

{-|
Module      : Stack.IDE
Description : Types and functions related to Stack's @ide@ command.
License     : BSD-3-Clause

Types and functions related to Stack's @ide@ command.
-}

module Stack.IDE
  ( OutputStream (..)
  , ListPackagesCmd (..)
  , idePackagesCmd
  , ideTargetsCmd
  , listPackages
  , listTargets
  ) where

import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Data.Text as T
import           Data.Tuple ( swap )
import           Stack.Prelude
import           Stack.Runners
                   ( ShouldReexec (..), withBuildConfig, withConfig )
import           Stack.Types.BuildConfig
                   ( BuildConfig (..), HasBuildConfig (..) )
import           Stack.Types.IdeOpts ( ListPackagesCmd (..), OutputStream (..) )
import           Stack.Types.NamedComponent
                   ( NamedComponent, isCBench, isCExe, isCTest
                   , renderPkgComponent
                   )
import           Stack.Types.Runner ( Runner )
import           Stack.Types.SourceMap
                   ( ProjectPackage (..), SMWanted (..), ppComponentsMaybe )
import           System.IO ( putStrLn )

-- | Function underlying the @stack ide packages@ command. List packages in the
-- project.
idePackagesCmd :: (OutputStream, ListPackagesCmd) -> RIO Runner ()
idePackagesCmd =
  withConfig NoReexec . withBuildConfig . uncurry listPackages

compTypes :: (Bool, Bool, Bool) -> NamedComponent -> Bool
compTypes (False, False, False) = const True
compTypes (exe, test, bench) =
  \x -> (exe && isCExe x) || (test && isCTest x) || (bench && isCBench x)

-- | Function underlying the @stack ide targets@ command. List targets in the
-- project.
ideTargetsCmd :: ((Bool, Bool, Bool), OutputStream)  -> RIO Runner ()
ideTargetsCmd = withConfig NoReexec .
  withBuildConfig . uncurry listTargets . fmap compTypes . swap

outputFunc :: HasTerm env => OutputStream -> String -> RIO env ()
outputFunc OutputLogInfo = prettyInfo . fromString
outputFunc OutputStdout  = liftIO . putStrLn

-- | List the packages inside the current project.
listPackages ::
     HasBuildConfig env
  => OutputStream
  -> ListPackagesCmd
  -> RIO env ()
listPackages stream flag = do
  packages <- view $ buildConfigL . to (.smWanted.project)
  let strs = case flag of
        ListPackageNames ->
          map packageNameString (Map.keys packages)
        ListPackageCabalFiles ->
          map (toFilePath . (.cabalFP)) (Map.elems packages)
  mapM_ (outputFunc stream) strs

-- | List the targets in the current project.
listTargets ::
     forall env. HasBuildConfig env
  => OutputStream
  -> (NamedComponent -> Bool)
  -> RIO env ()
listTargets stream isCompType = do
  packages <- view $ buildConfigL . to (.smWanted.project)
  pairs <- concat <$> Map.traverseWithKey toNameAndComponent packages
  outputFunc stream $ T.unpack $ T.intercalate "\n" $
    map renderPkgComponent pairs
 where
  toNameAndComponent ::
       PackageName
    -> ProjectPackage
    -> RIO env [(PackageName, NamedComponent)]
  toNameAndComponent pkgName' =
    fmap (map (pkgName',) . Set.toList) . ppComponentsMaybe (\x ->
      if isCompType x then Just x else Nothing)
