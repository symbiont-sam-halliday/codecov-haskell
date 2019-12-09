module Main where

import           Control.Monad
import           Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as BSL
import           Data.List
import           Data.Maybe hiding (listToMaybe)
import           CodecovHaskellCmdLine
import           System.Console.CmdArgs
import           System.Environment (getEnv, getEnvironment)
import           System.Exit (exitFailure, exitSuccess)
import           Trace.Hpc.Codecov
import           Trace.Hpc.Codecov.Config (Config(Config))
import qualified Trace.Hpc.Codecov.Config as Config
import           Trace.Hpc.Codecov.Curl
import           Trace.Hpc.Codecov.Util

baseUrlApiV2 :: String
baseUrlApiV2 = "https://codecov.io/upload/v2"

getUrlApiV2 :: IO String
getUrlApiV2 = do
    env <- getEnvironment
    case snd <$> find (isJust . flip lookup env . fst) ciEnvVars of
        Just ((idParamName, idParamEnvVar), commitEnvVar, branchEnvVar) -> do
            idParamValue <- getEnv idParamEnvVar
            commit <- getEnv commitEnvVar
            branch <- getEnv branchEnvVar
            return $ baseUrlApiV2 ++ "?" ++ idParamName ++ "=" ++ idParamValue ++ "&commit=" ++ commit ++ "&branch=" ++ branch
        _ -> error "Unsupported CI service."
    where ciEnvVars = [
           ("TRAVIS", (("job", "TRAVIS_JOB_ID"), "TRAVIS_COMMIT", "TRAVIS_BRANCH")),
           ("JENKINS_HOME", (("job", "BUILD_NUMBER"), "GIT_COMMIT", "GIT_BRANCH")),
           ("CIRCLECI", (("job", "CIRCLE_BUILD_NUM"), "CIRCLE_SHA1", "CIRCLE_BRANCH")),
           ("GITLAB_CI", (("job", "CI_JOB_ID"), "CI_COMMIT_SHA", "CI_COMMIT_REF_NAME"))]

getUrlWithToken :: String -> String -> Maybe String -> IO String
getUrlWithToken apiUrl _ Nothing = return apiUrl
getUrlWithToken apiUrl param (Just t) = do
  let separator = if '?' `elem` apiUrl then "&" else "?"
  return $ apiUrl ++ separator ++ param ++ "=" ++ t

getConfig :: CodecovHaskellArgs -> Maybe Config
getConfig cha = do _testSuites <- listToMaybe (testSuites cha)
                   return Config { Config.excludedDirs = excludeDirs cha
                                 , Config.testSuites   = _testSuites
                                 , Config.packages   = packages cha
                                 , Config.prefix   = prefix cha
                                 , Config.tixDir       = tixDir cha
                                 , Config.mixDir       = mixDir cha
                                 , Config.combined     = combined cha
                                 }

main :: IO ()
main = do
    cha <- cmdArgs codecovHaskellArgs
    case getConfig cha of
        Nothing -> putStrLn "Please specify a target test suite name" >> exitSuccess
        Just config -> do
            codecovJson <- generateCodecovFromTix config
            when (displayReport cha) $ BSL.putStrLn $ encode codecovJson
            unless (dontSend cha) $ do
                apiUrl <- getUrlApiV2
                fullUrl <- getUrlWithToken apiUrl "token" (token cha)
                response <- postJson (BSL.unpack $ encode codecovJson) fullUrl (printResponse cha)
                case response of
                    PostSuccess url _ -> do
                        responseUrl <- getUrlWithToken url "access_token" (accessToken cha)
                        putStrLn ("URL: " ++ responseUrl)
                        exitSuccess
                    PostFailure msg -> putStrLn ("Error: " ++ msg) >> exitFailure
