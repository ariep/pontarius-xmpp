{-

Copyright © 2010-2012 Jon Kristensen.

This file (EchoClient.hs) illustrates how to connect, authenticate, set a simple
presence, receive message stanzas, and echo them back to whoever is sending
them, using Pontarius. The contents of this file may be used freely, as if it is
in the public domain.

-}


{-# LANGUAGE OverloadedStrings #-}


module Main (main) where

import Control.Monad (forever)
import Control.Monad.IO.Class (liftIO)
import Data.Maybe (fromJust, isJust)

import Network.Xmpp
import Network.Xmpp.IM


-- Server and authentication details.

hostname = "localhost"

-- portNumber = 5222 -- TODO
username = ""
password = ""
resource = Nothing


-- TODO: Incomplete code, needs documentation, etc.
main :: IO ()
main = do
    session <- newSession
    withConnection (simpleConnect hostname username password resource) session
    sendPresence presenceOnline session
    echo session
    return ()

-- Pull message stanzas, verify that they originate from a `full' XMPP
-- address, and, if so, `echo' the message back.
echo :: Session -> IO ()
echo session = forever $ do
    result <- pullMessage session
    case result of
        Right message ->
            if (isJust $ messageFrom message) &&
                   (isFull $ fromJust $ messageFrom message) then do
                -- TODO: May not set from.
                sendMessage (Message Nothing (messageTo message) (messageFrom message) Nothing (messageType message) (messagePayload message)) session
                liftIO $ putStrLn "Message echoed!"
            else liftIO $ putStrLn "Message sender is not set or is bare!"
        Left exception -> liftIO $ putStrLn "Error: "