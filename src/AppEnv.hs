{-# LANGUAGE OverloadedStrings #-}

module AppEnv where

import Control.Monad.IO.Class
import Data.Text
import System.Environment

-- These are the Environmental variables available to the program
data AppEnv
  = AppEnv
      { sslKey :: Text,
        sslSecret :: Text,
        broker :: Text,
        srKey :: Text,
        srPass :: Text,
        srURL :: Text
      }
  deriving (Show)

-- Read the Environmental variables
readAppEnv :: (MonadIO m) => m AppEnv
readAppEnv = do
  let getEnv' key = liftIO $ pack <$> getEnv key
  _sslKey <- getEnv' "SSL_KEY"
  _sslSecret <- getEnv' "SSL_SECRET"
  _broker <- getEnv' "BROKER"
  _srKey <- getEnv' "SCHEMA_REGISTRY_KEY"
  _srPass <- getEnv' "SCHEMA_REGISTRY_PASS"
  _srURL <- getEnv' "SCHEMA_REGISTRY_URL"
  return $ AppEnv _sslKey _sslSecret _broker _srKey _srPass _srURL
