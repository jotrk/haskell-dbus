{-# LANGUAGE OverloadedStrings #-}

-- Copyright (C) 2009-2012 John Millikin <jmillikin@gmail.com>
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

module DBus.Constants where

import           DBus.Types

dbusName :: BusName
dbusName = "org.freedesktop.DBus"

dbusPath :: ObjectPath
dbusPath = "/org/freedesktop/DBus"

dbusInterface :: InterfaceName
dbusInterface = "org.freedesktop.DBus"

interfaceIntrospectable :: InterfaceName
interfaceIntrospectable = "org.freedesktop.DBus.Introspectable"

interfacePeer :: InterfaceName
interfacePeer = "org.freedesktop.DBus.Peer"

interfaceProperties :: InterfaceName
interfaceProperties = "org.freedesktop.DBus.Properties"

errorAccessDenied :: ErrorName
errorAccessDenied = "org.freedesktop.DBus.Error.AccessDenied"

errorAuthFailed :: ErrorName
errorAuthFailed = "org.freedesktop.DBus.Error.AuthFailed"

errorDisconnected :: ErrorName
errorDisconnected = "org.freedesktop.DBus.Error.Disconnected"

errorFailed :: ErrorName
errorFailed = "org.freedesktop.DBus.Error.Failed"

errorNoReply :: ErrorName
errorNoReply = "org.freedesktop.DBus.Error.NoReply"

errorNoServer :: ErrorName
errorNoServer = "org.freedesktop.DBus.Error.NoServer"

errorTimedOut :: ErrorName
errorTimedOut = "org.freedesktop.DBus.Error.TimedOut"

errorTimeout :: ErrorName
errorTimeout = "org.freedesktop.DBus.Error.Timeout"

errorServiceUnknown :: ErrorName
errorServiceUnknown = "org.freedesktop.DBus.Error.ServiceUnknown"

errorUnknownObject :: ErrorName
errorUnknownObject = "org.freedesktop.DBus.Error.UnknownObject"

errorUnknownInterface :: ErrorName
errorUnknownInterface = "org.freedesktop.DBus.Error.UnknownInterface"

errorUnknownMethod :: ErrorName
errorUnknownMethod = "org.freedesktop.DBus.Error.UnknownMethod"

errorInvalidParameters :: ErrorName
errorInvalidParameters = "org.freedesktop.DBus.Error.InvalidParameters"

errorSpawnChildExited :: ErrorName
errorSpawnChildExited = "org.freedesktop.DBus.Error.Spawn.ChildExited"

errorSpawnChildSignaled :: ErrorName
errorSpawnChildSignaled = "org.freedesktop.DBus.Error.Spawn.ChildSignaled"

errorSpawnConfigInvalid :: ErrorName
errorSpawnConfigInvalid = "org.freedesktop.DBus.Error.Spawn.ConfigInvalid"

errorSpawnExecFailed :: ErrorName
errorSpawnExecFailed = "org.freedesktop.DBus.Error.Spawn.ExecFailed"

errorSpawnForkFailed :: ErrorName
errorSpawnForkFailed = "org.freedesktop.DBus.Error.Spawn.ForkFailed"

errorSpawnFailed :: ErrorName
errorSpawnFailed = "org.freedesktop.DBus.Error.Spawn.Failed"

errorSpawnFailedToSetup :: ErrorName
errorSpawnFailedToSetup = "org.freedesktop.DBus.Error.Spawn.FailedToSetup"

errorSpawnFileInvalid :: ErrorName
errorSpawnFileInvalid = "org.freedesktop.DBus.Error.Spawn.FileInvalid"

errorSpawnNoMemory :: ErrorName
errorSpawnNoMemory = "org.freedesktop.DBus.Error.Spawn.NoMemory"

errorSpawnPermissionsInvalid :: ErrorName
errorSpawnPermissionsInvalid = "org.freedesktop.DBus.Error.Spawn.PermissionsInvalid"

errorSpawnServiceNotFound :: ErrorName
errorSpawnServiceNotFound = "org.freedesktop.DBus.Error.Spawn.ServiceNotFound"

errorSpawnServiceNotValid :: ErrorName
errorSpawnServiceNotValid = "org.freedesktop.DBus.Error.Spawn.ServiceNotValid"

errorAddressInUse :: ErrorName
errorAddressInUse = "org.freedesktop.DBus.Error.AddressInUse"

errorAdtAuditDataUnknown :: ErrorName
errorAdtAuditDataUnknown = "org.freedesktop.DBus.Error.AdtAuditDataUnknown"

errorBadAddress :: ErrorName
errorBadAddress = "org.freedesktop.DBus.Error.BadAddress"

errorFileExists :: ErrorName
errorFileExists = "org.freedesktop.DBus.Error.FileExists"

errorFileNotFound :: ErrorName
errorFileNotFound = "org.freedesktop.DBus.Error.FileNotFound"

errorInconsistentMessage :: ErrorName
errorInconsistentMessage = "org.freedesktop.DBus.Error.InconsistentMessage"

errorInvalidFileContent :: ErrorName
errorInvalidFileContent = "org.freedesktop.DBus.Error.InvalidFileContent"

errorIOError :: ErrorName
errorIOError = "org.freedesktop.DBus.Error.IOError"

errorLimitsExceeded :: ErrorName
errorLimitsExceeded = "org.freedesktop.DBus.Error.LimitsExceeded"

errorMatchRuleInvalid :: ErrorName
errorMatchRuleInvalid = "org.freedesktop.DBus.Error.MatchRuleInvalid"

errorMatchRuleNotFound :: ErrorName
errorMatchRuleNotFound = "org.freedesktop.DBus.Error.MatchRuleNotFound"

errorNameHasNoOwner :: ErrorName
errorNameHasNoOwner = "org.freedesktop.DBus.Error.NameHasNoOwner"

errorNoMemory :: ErrorName
errorNoMemory = "org.freedesktop.DBus.Error.NoMemory"

errorNoNetwork :: ErrorName
errorNoNetwork = "org.freedesktop.DBus.Error.NoNetwork"

errorNotSupported :: ErrorName
errorNotSupported = "org.freedesktop.DBus.Error.NotSupported"

errorObjectPathInUse :: ErrorName
errorObjectPathInUse = "org.freedesktop.DBus.Error.ObjectPathInUse"

errorSELinuxSecurityContextUnknown :: ErrorName
errorSELinuxSecurityContextUnknown = "org.freedesktop.DBus.Error.SELinuxSecurityContextUnknown"

errorUnixProcessIdUnknown :: ErrorName
errorUnixProcessIdUnknown = "org.freedesktop.DBus.Error.UnixProcessIdUnknown"