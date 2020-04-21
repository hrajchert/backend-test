{-# LANGUAGE OverloadedStrings #-}

module Lib where

--   ( someFunc,
--     testOrder,
--   )

import Data.Avro
import Data.Text
import qualified TestTopic as TT

what = encodeValue testTopic

testItem = TT.Items "somesku" "27.05"

testOrder = TT.Order TT.StatusPENDING "hola@email" [testItem]

testTopic = TT.Value 32 testOrder

someFunc :: IO ()
someFunc = putStrLn "someFunc"
