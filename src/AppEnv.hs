{-# LANGUAGE OverloadedStrings #-}

module AppEnv where

import Control.Monad.IO.Class
import Data.Text
import System.Environment

data AppEnv
  = AppEnv
      { sslKey :: Text,
        sslSecret :: Text,
        broker :: Text
      }
  deriving (Show)

readAppEnv :: (MonadIO m) => m AppEnv
readAppEnv = do
  let getEnv' key = liftIO $ getEnv key
  key <- getEnv' "SSL_KEY"
  secret <- getEnv' "SSL_SECRET"
  servers <- getEnv' "BROKER"
  return $ AppEnv (pack key) (pack secret) (pack servers)
