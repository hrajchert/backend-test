{-# LANGUAGE OverloadedStrings #-}

module Lib where

--   ( someFunc,
--     testOrder,
--   )

import Data.Avro
import Data.Text
import qualified TestTopic as TT

testItem1 = TT.Items "xyz" "28.8"

testItem2 = TT.Items "xyz" "30.1"

testOrder = TT.Order TT.StatusPENDING "some@email-from-haskell.com" [testItem1, testItem2]

testTopic = TT.Value 7 testOrder
