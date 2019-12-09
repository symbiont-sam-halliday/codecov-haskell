module Trace.Hpc.Codecov.Config where

data Config = Config {
    excludedDirs :: ![FilePath],
    packages     :: ![FilePath],
    testSuites   :: ![String],
    tixDir       :: !FilePath,
    mixDir       :: !FilePath,
    prefix       :: !FilePath,
    combined     :: !Bool
    }
