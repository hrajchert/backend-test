{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import Data.Aeson
import Data.Time (UTCTime (..))
import Data.Time.Calendar
import Data.Time.Clock
import GHC.Generics
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Servant.API

-- type UserAPI = "users" :> QueryParam "sortby" SortBy :> Get '[JSON] [User]

type UserAPI = "users" :> Get '[JSON] [User]

userAPI :: Proxy UserAPI
userAPI = Proxy

data SortBy = Age | Name

data User
  = User
      { name :: String,
        age :: Int,
        email :: String,
        registration_date :: UTCTime
      }
  deriving (Generic, Show)

instance ToJSON User

mockUsers :: [User]
mockUsers =
  [ User "John" 28 "john@gmail.com" (UTCTime (fromGregorian 2020 4 20) (secondsToDiffTime 1500))
  ]

server :: Server UserAPI
server = return mockUsers

app :: Application
app = serve userAPI server

main :: IO ()
main = do
  putStrLn "Hey ho"
  putStrLn "Lets go"
  run 8081 app
