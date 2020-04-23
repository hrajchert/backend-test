{-# LANGUAGE OverloadedStrings #-}

module Lib
  ( runProducerExample,
  )
where

import AppEnv
import Control.Exception (bracket)
import Control.Monad.IO.Class
import qualified Data.ByteString.Lazy as Lazy
import Data.Kafka.TestTopic
import qualified Data.Map as Map
import Data.Text
import Data.Text.Encoding (encodeUtf8)
import Kafka.Avro
import Kafka.Producer
import qualified Network.Wreq as Wreq

-- Produce a TestTopic in kafka
runProducerExample :: AppEnv -> TestTopic -> IO ()
runProducerExample appEnv topic = do
  registry <- createSchemaRegistry appEnv
  encoded <- encodeTopic registry topic
  let mkProducer = newProducer (producerProps appEnv)
      clProducer (Left _) = return ()
      clProducer (Right prod) = closeProducer prod
      runHandler (Left err) = return $ Left err
      runHandler (Right prod) = produceTopic encoded prod
  _ <- bracket mkProducer clProducer runHandler
  pure ()

-- Global producer properties
producerProps :: AppEnv -> ProducerProperties
producerProps appEnv =
  brokersList [BrokerAddress (broker appEnv)]
    <> sendTimeout (Timeout 5000)
    <> extraProps
      ( Map.fromList
          [ ("security.protocol", "sasl_ssl"),
            ("sasl.mechanism", "PLAIN"),
            ("sasl.password", sslSecret appEnv),
            ("sasl.username", sslKey appEnv)
          ]
      )
    --  <> logLevel KafkaLogDebug
    -- <> logLevel KafkaLogInfo
    -- <> debugOptions [DebugAll]
    -- TODO: I don't Like this setCallback that prints the result but doesn't
    --       give me a way to check the results
    <> setCallback (deliveryCallback print)

createSchemaRegistry :: (MonadIO m) => AppEnv -> m SchemaRegistry
createSchemaRegistry env = schemaRegistry_ (Just $ Wreq.basicAuth key pass) url
  where
    url = unpack $ srURL env
    key = encodeUtf8 $ srKey env
    pass = encodeUtf8 $ srPass env

data EncodedTopic
  = EncodedTopic
      { encName :: Text,
        encKey :: Lazy.ByteString,
        encVal :: Lazy.ByteString
      }

encodeTopic :: (MonadIO m) => SchemaRegistry -> TestTopic -> m EncodedTopic
encodeTopic sr topic = do
  let subject = Subject (ttName topic)
  -- Call the SchemaRegistry to encode both key and value
  maybeKey <- encodeKey sr subject (ttKey topic)
  maybeValue <- encodeValue sr subject (ttValue topic)
  -- Put them inside a new object
  let maybeEncodedTopic :: Either EncodeError EncodedTopic
      maybeEncodedTopic = EncodedTopic <$> Right (ttName topic) <*> maybeKey <*> maybeValue
  -- If there is an error throw it as an Exception
  -- TODO: see if it's worth to use UnliftIO's fromEither or
  -- https://hackage.haskell.org/package/unliftio-0.2.12.1/docs/UnliftIO-Exception.html#v:fromEither
  case maybeEncodedTopic of
    (Right encodedTopic) -> pure encodedTopic
    (Left err) -> error $ "some error " <> show err

produceTopic :: (MonadIO m) => EncodedTopic -> KafkaProducer -> m (Either KafkaError ())
produceTopic encoded producer = do
  let message =
        ProducerRecord
          { prTopic = TopicName (encName encoded),
            prPartition = UnassignedPartition,
            prKey = Just $ Lazy.toStrict (encKey encoded),
            prValue = Just $ Lazy.toStrict (encVal encoded)
          }
  maybeError <- produceMessage producer message
  case maybeError of
    Nothing -> pure $ Right ()
    (Just err) -> pure $ Left err
