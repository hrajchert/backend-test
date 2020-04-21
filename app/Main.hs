{-# LANGUAGE OverloadedStrings #-}

module Main where

-- import Kafka.Avro

import AppEnv
import Control.Exception (bracket)
import Control.Monad (forM_)
import Data.Avro
import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as Lazy
import qualified Data.Map as Map
import Kafka.Producer
import Lib

-- Global producer properties
producerProps :: AppEnv -> ProducerProperties
producerProps appEnv =
  brokersList [BrokerAddress (broker appEnv)]
    <> sendTimeout (Timeout 5000)
    <> extraProps
      ( Map.fromList
          [ ("security.protocol", "sasl_ssl"),
            ("sasl.mechanism", "PLAIN"),
            ("sasl.password", (sslSecret appEnv)),
            ("sasl.username", (sslKey appEnv))
          ]
      )
    --  <> logLevel KafkaLogDebug
    -- <> logLevel KafkaLogInfo
    -- <> debugOptions [DebugAll]
    <> setCallback (deliveryCallback print)

-- Topic to send messages to
targetTopic :: TopicName
targetTopic = TopicName "test.kafka.client"

-- Run an example
runProducerExample :: AppEnv -> IO ()
runProducerExample appEnv =
  bracket mkProducer clProducer runHandler >>= \_ -> pure ()
  where
    mkProducer = newProducer (producerProps appEnv)
    clProducer (Left _) = return ()
    clProducer (Right prod) = closeProducer prod
    runHandler (Left err) = return $ Left err
    runHandler (Right prod) = sendMessages prod

encodedTopic :: ByteString
encodedTopic = Lazy.toStrict $ encodeValue testTopic

encodedKey :: ByteString
encodedKey = Lazy.toStrict $ encodeValue ("hey jude" :: ByteString)

-- encodeTopic :: SchemaRegistry -> IO (Either EncodeError Lazy.ByteString)
-- encodeTopic sr = encodeValue sr (Subject "test.kafka.client") testTopic

-- runEncodeTestTopic :: IO ()
-- runEncodeTestTopic =
--   do
--     registry <- schemaRegistry "https://key:pass@schemaRegistry"
--     encoded <- encodeTopic registry
--     case encoded of
--       (Right text) -> putStrLn $ show text
--       (Left err) -> putStrLn "some error"
--     pure ()

-- schemaR :: SchemaRegistry
-- schemaR = schemaRegistry "sas"

sendMessages :: KafkaProducer -> IO (Either KafkaError ())
sendMessages prod = do
  putStrLn $ show encodedKey
  putStrLn $ show encodedTopic
  err1 <- produceMessage prod (mkMessage (Just encodedKey) (Just encodedTopic)) -- (_ encodedTopic schemaR))
  forM_ err1 print
  -- err2 <- produceMessage prod (mkMessage (Just "key") (Just "test from producer (with key)"))
  -- forM_ err2 print
  return $ Right ()

mkMessage :: Maybe ByteString -> Maybe ByteString -> ProducerRecord
mkMessage k v =
  ProducerRecord
    { prTopic = targetTopic,
      prPartition = UnassignedPartition,
      prKey = k,
      prValue = v
    }

main :: IO ()
main = do
  someFunc
  putStrLn "Starting..."
  env <- readAppEnv
  putStrLn $ show env
  runProducerExample env
  -- runEncodeTestTopic
  putStrLn "Ending..."
