{-# LANGUAGE OverloadedStrings #-}

module Main where

import AppEnv
import Control.Exception (bracket)
import Control.Monad (forM_)
import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as Lazy
import qualified Data.Map as Map
import Data.Text
import Data.Text.Encoding (encodeUtf8)
import Kafka.Avro
import Kafka.Producer
import Lib
import qualified Network.Wreq as Wreq

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
runProducerExample appEnv = do
  encoded <- runEncodeTestTopic appEnv
  _ <- bracket mkProducer clProducer (runHandler encoded)
  pure ()
  where
    mkProducer = newProducer (producerProps appEnv)
    clProducer (Left _) = return ()
    clProducer (Right prod) = closeProducer prod
    runHandler _ (Left err) = return $ Left err
    runHandler encoded (Right prod) = (sendMessages encoded) prod

encodeTopic :: SchemaRegistry -> IO (Either EncodeError Lazy.ByteString)
encodeTopic sr = encodeValue sr (Subject "test.kafka.client") testTopic

encodeKey_ :: SchemaRegistry -> IO (Either EncodeError Lazy.ByteString)
encodeKey_ sr = encodeKey sr (Subject "test.kafka.client") ("from haskell" :: Text)

encodePair :: SchemaRegistry -> IO (Either EncodeError (Lazy.ByteString, Lazy.ByteString))
encodePair sr = do
  maybeKey <- encodeKey_ sr
  maybeValue <- encodeTopic sr
  pure $ do
    key <- maybeKey
    value <- maybeValue
    pure (key, value)

runEncodeTestTopic :: AppEnv -> IO (Lazy.ByteString, Lazy.ByteString)
runEncodeTestTopic env =
  do
    let url = unpack $ srURL env
        key = encodeUtf8 $ srKey env
        pass = encodeUtf8 $ srPass env
    registry <- schemaRegistry_ (Just $ Wreq.basicAuth key pass) url
    encoded <- encodePair registry
    case encoded of
      (Right pair) -> pure pair
      (Left err) -> error $ "some error " <> show err

sendMessages :: (Lazy.ByteString, Lazy.ByteString) -> KafkaProducer -> IO (Either KafkaError ())
sendMessages encoded prod = do
  let key = fst encoded
      topic = snd encoded
  err1 <- produceMessage prod (mkMessage (Just $ Lazy.toStrict key) (Just $ Lazy.toStrict topic))
  forM_ err1 print
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
  putStrLn "Starting..."
  env <- readAppEnv
  runProducerExample env
  putStrLn "Ending..."
