{-# LANGUAGE DeriveDataTypeable #-}

module CodecovHaskellCmdLine where

import Data.List
import Data.Version (Version(..))
import Paths_codecov_haskell (version)
import System.Console.CmdArgs
import Trace.Hpc.Codecov.Paths (defaultTixDir,defaultMixDir)

data CodecovHaskellArgs = CmdMain
    { token         :: Maybe String
    , accessToken   :: Maybe String
    , excludeDirs   :: [String]
    , testSuites    :: [String]
    , prefix        :: String
    , tixDir        :: FilePath
    , mixDir        :: FilePath
    , packages      :: [FilePath]
    , displayReport :: Bool
    , printResponse :: Bool
    , dontSend      :: Bool
    , combined      :: Bool
    } deriving (Data, Show, Typeable)

codecovHaskellArgs :: CodecovHaskellArgs
codecovHaskellArgs = CmdMain
    { token         = Nothing        &= explicit &= typDir     &= name "token"          &= help "Codecov upload token for this repository"
    , accessToken   = Nothing        &= explicit &= typDir     &= name "access-token"   &= help "Codecov access token to retrieve reports for private repos"
    , excludeDirs   = []             &= explicit &= typDir     &= name "exclude-dir"    &= help "Exclude sources files under the matching directory from the coverage report"
    , packages       = []            &= explicit &= typDir     &= name "packages"       &= help "Generate coverage for these packages within the current directory"
    , tixDir        = defaultTixDir  &= explicit &= typDir     &= name "tix-dir"        &= help "Directory where .tix files are located"
    , mixDir        = defaultMixDir  &= explicit &= typDir     &= name "mix-dir"        &= help "Directory where .mix files are located"
    , prefix        = ""             &= explicit &= typDir     &= name "prefix"         &= help "Prefix to prepend to all source file names relative to the current directory"
    , displayReport = False          &= explicit               &= name "display-report" &= help "Display the json code coverage report that will be sent to codecov.io"
    , printResponse = False          &= explicit               &= name "print-response" &= help "Prints the json reponse received from codecov.io"
    , dontSend      = False          &= explicit               &= name "dont-send"      &= help "Do not send the report to codecov.io"
    , combined      = True           &= explicit               &= name "combined"       &= help "Generate a report from a stack combined report"
    , testSuites    = []             &= typ "TEST-SUITE" &= args
    } &= summary ("codecov-haskell-" ++ versionString version ++ ", (C) Guillaume Nargeot 2014")
      &= program "codecov-haskell"
    where versionString = intercalate "." . map show . versionBranch
