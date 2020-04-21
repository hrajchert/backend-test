{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

module TestTopic
  ( Value (..),
    Order (..),
    Status (..),
    Items (..),
  )
where

-- schema'TestMessage,

-- import Data.Avro
import Data.Avro.Deriving (deriveAvroFromByteString, r)

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
