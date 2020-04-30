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
    $ order
      (Id 7)
      StatusPENDING
      "some@email-from-haskell.com"
      [item "xyz" "28.8", item "xyz" "30.1"]

main :: IO ()
main = do
  putStrLn "Starting..."
  env <- readAppEnv
  runProducerExample env testTopic
  putStrLn "Ending..."
