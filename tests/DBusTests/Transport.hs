{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

-- Copyright (C) 2012 John Millikin <jmillikin@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

module DBusTests.Transport (test_Transport) where

import           Test.Chell

import           Control.Concurrent
import           Control.Monad.IO.Class (MonadIO, liftIO)
import qualified Data.ByteString
import           Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as Char8
import           Data.List (isPrefixOf)
import qualified Data.Map as Map
import qualified Network as N
import qualified Network.Socket as NS
import           System.Directory (getTemporaryDirectory, removeFile)
import           System.IO

import           DBus
import           DBus.Transport

import           DBusTests.Util

test_Transport :: Suite
test_Transport = suite "Transport"
	[ test_TransportOpen
	, test_TransportListen
	, test_TransportAccept
	, test_TransportSendReceive
	]

test_TransportOpen :: Suite
test_TransportOpen = suite "transportOpen"
	[ test_OpenUnknown
	, test_OpenUnix
	, test_OpenTcp
	]

test_TransportListen :: Suite
test_TransportListen = suite "transportListen"
	[ test_ListenUnknown
	, test_ListenUnix
	, test_ListenTcp
	]

test_TransportAccept :: Suite
test_TransportAccept = suite "transportAccept"
	[ test_AcceptSocket
	, test_AcceptSocketClosed
	]

test_OpenUnknown :: Suite
test_OpenUnknown = assertions "unknown" $ do
	let addr = address_ "noexist" Map.empty
	$assert $ throwsEq
		((transportError "Unknown address method: \"noexist\"")
			{ transportErrorAddress = Just addr
			})
		(transportOpen socketTransportOptions addr)

test_OpenUnix :: Suite
test_OpenUnix = suite "unix"
	[ test_OpenUnix_Path
	, test_OpenUnix_Abstract
	, test_OpenUnix_TooFew
	, test_OpenUnix_TooMany
	, test_OpenUnix_NotListening
	]

test_OpenUnix_Path :: Suite
test_OpenUnix_Path = assertions "path" $ do
	(addr, networkSocket) <- listenRandomUnixPath
	afterTest (N.sClose networkSocket)
	
	t <- liftIO (transportOpen socketTransportOptions addr)
	afterTest (transportClose t)

test_OpenUnix_Abstract :: Suite
test_OpenUnix_Abstract = assertions "abstract" $ do
	(addr, networkSocket) <- listenRandomUnixAbstract
	afterTest (N.sClose networkSocket)
	
	t <- liftIO (transportOpen socketTransportOptions addr)
	afterTest (transportClose t)

test_OpenUnix_TooFew :: Suite
test_OpenUnix_TooFew = assertions "too-few" $ do
	let addr = address_ "unix" Map.empty
	$assert $ throwsEq
		((transportError "One of 'path' or 'abstract' must be specified for the 'unix' transport.")
			{ transportErrorAddress = Just addr
			})
		(transportOpen socketTransportOptions addr)

test_OpenUnix_TooMany :: Suite
test_OpenUnix_TooMany = assertions "too-many" $ do
	let addr = address_ "unix" (Map.fromList
		[ ("path", "foo")
		, ("abstract", "bar")
		])
	$assert $ throwsEq
		((transportError "Only one of 'path' or 'abstract' may be specified for the 'unix' transport.")
			{ transportErrorAddress = Just addr
			})
		(transportOpen socketTransportOptions addr)

test_OpenUnix_NotListening :: Suite
test_OpenUnix_NotListening = assertions "not-listening" $ do
	(addr, networkSocket) <- listenRandomUnixAbstract
	liftIO (NS.sClose networkSocket)
	$assert $ throwsEq
		((transportError "connect: does not exist (Connection refused)")
			{ transportErrorAddress = Just addr
			})
		(transportOpen socketTransportOptions addr)

test_OpenTcp :: Suite
test_OpenTcp = suite "tcp"
	[ test_OpenTcp_IPv4
	, skipWhen noIPv6 test_OpenTcp_IPv6
	, test_OpenTcp_Unknown
	, test_OpenTcp_NoPort
	, test_OpenTcp_InvalidPort
	, test_OpenTcp_NoUsableAddresses
	, test_OpenTcp_NotListening
	]

test_OpenTcp_IPv4 :: Suite
test_OpenTcp_IPv4 = assertions "ipv4" $ do
	(addr, networkSocket) <- listenRandomIPv4
	afterTest (N.sClose networkSocket)
	
	t <- liftIO (transportOpen socketTransportOptions addr)
	afterTest (transportClose t)

test_OpenTcp_IPv6 :: Suite
test_OpenTcp_IPv6 = assertions "ipv6" $ do
	(addr, networkSocket) <- listenRandomIPv6
	afterTest (N.sClose networkSocket)
	
	t <- liftIO (transportOpen socketTransportOptions addr)
	afterTest (transportClose t)

test_OpenTcp_Unknown :: Suite
test_OpenTcp_Unknown = assertions "unknown-family" $ do
	let addr = address_ "tcp" (Map.fromList
		[ ("family", "noexist")
		, ("port", "1234")
		])
	$assert $ throwsEq
		((transportError "Unknown socket family for TCP transport: \"noexist\"")
			{ transportErrorAddress = Just addr
			})
		(transportOpen socketTransportOptions addr)

test_OpenTcp_NoPort :: Suite
test_OpenTcp_NoPort = assertions "no-port" $ do
	let addr = address_ "tcp" (Map.fromList
		[ ("family", "ipv4")
		])
	$assert $ throwsEq
		((transportError "TCP transport requires the `port' parameter.")
			{ transportErrorAddress = Just addr
			})
		(transportOpen socketTransportOptions addr)

test_OpenTcp_InvalidPort :: Suite
test_OpenTcp_InvalidPort = assertions "invalid-port" $ do
	let addr = address_ "tcp" (Map.fromList
		[ ("family", "ipv4")
		, ("port", "123456")
		])
	$assert $ throwsEq
		((transportError "Invalid socket port for TCP transport: \"123456\"")
			{ transportErrorAddress = Just addr
			})
		(transportOpen socketTransportOptions addr)

test_OpenTcp_NoUsableAddresses :: Suite
test_OpenTcp_NoUsableAddresses = assertions "no-usable-addresses" $ do
	let addr = address_ "tcp" (Map.fromList
		[ ("family", "ipv4")
		, ("port", "1234")
		, ("host", "256.256.256.256")
		])
	$assert $ throws
		(\err -> and
			[ "getAddrInfo: does not exist" `isPrefixOf` transportErrorMessage err
			, transportErrorAddress err == Just addr
			])
		(transportOpen socketTransportOptions addr)

test_OpenTcp_NotListening :: Suite
test_OpenTcp_NotListening = assertions "too-many" $ do
	(addr, networkSocket) <- listenRandomIPv4
	liftIO (NS.sClose networkSocket)
	$assert $ throwsEq
		((transportError "connect: does not exist (Connection refused)")
			{ transportErrorAddress = Just addr
			})
		(transportOpen socketTransportOptions addr)

test_TransportSendReceive :: Suite
test_TransportSendReceive = assertions "send-receive" $ do
	(addr, networkSocket) <- listenRandomIPv4
	afterTest (N.sClose networkSocket)
	_ <- liftIO $ forkIO $ do
		(h, _, _) <- N.accept networkSocket
		hSetBuffering h LineBuffering
		
		bytes <- Data.ByteString.hGetLine h
		Data.ByteString.hPut h bytes
		hFlush h
		hClose h
		NS.sClose networkSocket
	
	t <- liftIO (transportOpen socketTransportOptions addr)
	afterTest (transportClose t)
	
	liftIO (transportPut t "testing\n")
	bytes1 <- liftIO (transportGet t 2)
	bytes2 <- liftIO (transportGet t 100)
	
	$expect (equal bytes1 "te")
	$expect (equal bytes2 "sting")

test_ListenUnknown :: Suite
test_ListenUnknown = assertions "unknown" $ do
	let addr = address_ "noexist" Map.empty
	$assert $ throwsEq
		((transportError "Unknown address method: \"noexist\"")
			{ transportErrorAddress = Just addr
			})
		(transportListen socketTransportOptions addr)

test_ListenUnix :: Suite
test_ListenUnix = suite "unix"
	[ test_ListenUnix_Path
	, test_ListenUnix_Abstract
	, test_ListenUnix_Tmpdir
	, test_ListenUnix_TooFew
	, test_ListenUnix_TooMany
	]

test_ListenUnix_Path :: Suite
test_ListenUnix_Path = assertions "path" $ do
	path <- liftIO getTempPath
	let addr = address_ "unix" (Map.fromList
		[ ("path", Char8.pack path)
		])
	l <- liftIO (transportListen socketTransportOptions addr)
	afterTest (transportListenerClose l)
	afterTest (removeFile path)
	
	-- listener address is random, so it can't be checked directly.
	let addrParams = addressParameters (transportListenerAddress l)
	$expect (sameItems (Map.keys addrParams) ["path", "guid"])
	$expect (equal (Map.lookup "path" addrParams) (Just (Char8.pack path)))

test_ListenUnix_Abstract :: Suite
test_ListenUnix_Abstract = assertions "abstract" $ do
	path <- liftIO getTempPath
	let addr = address_ "unix" (Map.fromList
		[ ("abstract", Char8.pack path)
		])
	l <- liftIO (transportListen socketTransportOptions addr)
	afterTest (transportListenerClose l)
	
	-- listener address is random, so it can't be checked directly.
	let addrParams = addressParameters (transportListenerAddress l)
	$expect (sameItems (Map.keys addrParams) ["abstract", "guid"])
	$expect (equal (Map.lookup "abstract" addrParams) (Just (Char8.pack path)))

test_ListenUnix_Tmpdir :: Suite
test_ListenUnix_Tmpdir = assertions "tmpdir" $ do
	tmpdir <- liftIO getTemporaryDirectory
	let addr = address_ "unix" (Map.fromList
		[ ("tmpdir", Char8.pack tmpdir)
		])
	l <- liftIO (transportListen socketTransportOptions addr)
	afterTest (transportListenerClose l)
	
	-- listener address is random, so it can't be checked directly.
	let addrKeys = Map.keys (addressParameters (transportListenerAddress l))
	$expect ("path" `elem` addrKeys || "abstract" `elem` addrKeys)

test_ListenUnix_TooFew :: Suite
test_ListenUnix_TooFew = assertions "too-few" $ do
	let addr = address_ "unix" Map.empty
	$assert $ throwsEq
		((transportError "One of 'abstract', 'path', or 'tmpdir' must be specified for the 'unix' transport.")
			{ transportErrorAddress = Just addr
			})
		(transportListen socketTransportOptions addr)

test_ListenUnix_TooMany :: Suite
test_ListenUnix_TooMany = assertions "too-many" $ do
	let addr = address_ "unix" (Map.fromList
		[ ("path", "foo")
		, ("abstract", "bar")
		])
	$assert $ throwsEq
		((transportError "Only one of 'abstract', 'path', or 'tmpdir' may be specified for the 'unix' transport.")
			{ transportErrorAddress = Just addr
			})
		(transportListen socketTransportOptions addr)

test_ListenTcp :: Suite
test_ListenTcp = suite "tcp"
	[ test_ListenTcp_IPv4
	, skipWhen noIPv6 test_ListenTcp_IPv6
	, test_ListenTcp_Unknown
	, test_ListenTcp_InvalidPort
	]

test_ListenTcp_IPv4 :: Suite
test_ListenTcp_IPv4 = assertions "ipv4" $ do
	let addr = address_ "tcp" (Map.fromList
		[ ("family", "ipv4")
		])
	l <- liftIO (transportListen socketTransportOptions addr)
	afterTest (transportListenerClose l)
	
	let params = addressParameters (transportListenerAddress l)
	$expect (equal (Map.lookup "family" params) (Just "ipv4"))
	$expect ("port" `elem` Map.keys params)

test_ListenTcp_IPv6 :: Suite
test_ListenTcp_IPv6 = assertions "ipv6" $ do
	let addr = address_ "tcp" (Map.fromList
		[ ("family", "ipv6")
		])
	l <- liftIO (transportListen socketTransportOptions addr)
	afterTest (transportListenerClose l)
	
	let params = addressParameters (transportListenerAddress l)
	$expect (equal (Map.lookup "family" params) (Just "ipv6"))
	$expect ("port" `elem` Map.keys params)

test_ListenTcp_Unknown :: Suite
test_ListenTcp_Unknown = assertions "unknown-family" $ do
	let addr = address_ "tcp" (Map.fromList
		[ ("family", "noexist")
		, ("port", "1234")
		])
	$assert $ throwsEq
		((transportError "Unknown socket family for TCP transport: \"noexist\"")
			{ transportErrorAddress = Just addr
			})
		(transportListen socketTransportOptions addr)

test_ListenTcp_InvalidPort :: Suite
test_ListenTcp_InvalidPort = assertions "invalid-port" $ do
	let addr = address_ "tcp" (Map.fromList
		[ ("family", "ipv4")
		, ("port", "123456")
		])
	$assert $ throwsEq
		((transportError "Invalid socket port for TCP transport: \"123456\"")
			{ transportErrorAddress = Just addr
			})
		(transportListen socketTransportOptions addr)

test_AcceptSocket :: Suite
test_AcceptSocket = assertions "socket" $ do
	path <- liftIO getTempPath
	let addr = address_ "unix" (Map.fromList
		[ ("abstract", Char8.pack path)
		])
	listener <- liftIO (transportListen socketTransportOptions addr)
	afterTest (transportListenerClose listener)
	
	acceptedVar <- forkVar (transportAccept listener)
	openedVar <- forkVar (transportOpen socketTransportOptions addr)
	
	accepted <- liftIO (readMVar acceptedVar)
	opened <- liftIO (readMVar openedVar)
	afterTest (transportClose accepted)
	afterTest (transportClose opened)
	
	liftIO (transportPut opened "testing")
	
	bytes1 <- liftIO (transportGet accepted 2)
	bytes2 <- liftIO (transportGet accepted 100)
	
	$expect (equal bytes1 "te")
	$expect (equal bytes2 "sting")

test_AcceptSocketClosed :: Suite
test_AcceptSocketClosed = assertions "socket-closed" $ do
	path <- liftIO getTempPath
	let addr = address_ "unix" (Map.fromList
		[ ("abstract", Char8.pack path)
		])
	listener <- liftIO (transportListen socketTransportOptions addr)
	let listeningAddr = transportListenerAddress listener
	liftIO (transportListenerClose listener)
	
	$assert $ throwsEq
		((transportError "user error (accept: can't perform accept on socket ((AF_UNIX,Stream,0)) in status Closed)")
			{ transportErrorAddress = Just listeningAddr
			})
		(transportAccept listener)

socketTransportOptions :: TransportOptions SocketTransport
socketTransportOptions = transportDefaultOptions

address_ :: ByteString -> Map.Map ByteString ByteString -> Address
address_ method params = case address method params of
	Just addr -> addr
	Nothing -> error "address_: invalid address"