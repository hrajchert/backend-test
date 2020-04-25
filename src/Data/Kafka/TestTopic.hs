{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

module Data.Kafka.TestTopic
  ( mkTestTopic,
    TestTopic (..),
    Status (..),
    item,
    order,
    Id (..),
  )
where

import Data.Avro.Deriving (deriveAvroFromByteString, r)
import Data.Text
import GHC.Int

type Key = Text

-- Generate Value types from the avro schema
deriveAvroFromByteString
  [r|
{
  "fields": [
    {
      "name": "id",
      "type": "int"
    },
    {
      "name": "order",
      "namespace": "saracatung",

      "type": {
        "fields": [
          {
            "name": "status",
            "type": {
              "name": "status",
              "symbols": [
                "PENDING",
                "DELIVERED"
              ],
              "type": "enum"
            }
          },
          {
            "name": "customerEmail",
            "type": "string"
          },
          {
            "name": "items",
            "type": {
              "items": {
                "fields": [
                  {
                    "name": "sku",
                    "type": "string"
                  },
                  {
                    "name": "price",
                    "type": "string"
                  }
                ],
                "name": "items",
                "namespace": "test.kafka.client.order.items",
                "type": "record"
              },
              "type": "array"
            }
          }
        ],
        "name": "order",
        "namespace": "test.kafka.client.order",
        "type": "record"
      }
    }
  ],
  "name": "value",
  "namespace": "test.kafka.client",
  "type": "record"
}
|]

data TestTopic
  = TestTopic
      { ttName :: Text,
        ttKey :: Key,
        ttValue :: Value
      }

mkTestTopic :: Key -> Value -> TestTopic
mkTestTopic = TestTopic "test.kafka.client"

newtype Id = Id Int32 deriving (Show)

order :: Id -> Status -> Text -> [Items] -> Value
order (Id _id) status email items = Value _id $ Order status email items

item :: Text -> Text -> Items
item = Items
