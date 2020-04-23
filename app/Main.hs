{-# LANGUAGE OverloadedStrings #-}

module Main where

import AppEnv
import Data.Kafka.TestTopic
import Lib

testTopic :: TestTopic
testTopic =
  mkTestTopic
    -- key
    "from haskell"
    $ Value
      7 -- id
      ( Order
          StatusPENDING
          "some@email-from-haskell.com"
          [Items "xyz" "28.8", Items "xyz" "30.1"]
      )

main :: IO ()
main = do
  putStrLn "Starting..."
  env <- readAppEnv
  runProducerExample env testTopic
  putStrLn "Ending..."
