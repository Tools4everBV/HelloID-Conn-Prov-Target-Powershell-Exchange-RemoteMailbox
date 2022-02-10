# HelloID-Conn-Prov-Target-Powershell-Exchange-RemoteMailbox
Powershell connector to create, enable(unhide) or disable(hide) through a hybrid Exchange server

| :information_source: Information |
|:---------------------------|
| This repository contains the powershell connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |

<br />

<p align="center">
  <img src="assets/logo.png" width="400">
</p>

## Table of contents

- [Introduction](#Introduction)
- [Getting started](#Getting-started)
  + [Connection settings](#Connection-settings)
  + [Prerequisites](#Prerequisites)
  + [Remarks](#Remarks)
- [Setup the connector](@Setup-The-Connector)
- [HelloID Docs](#HelloID-docs)
- [Forum Thread](#forum-thread)

## Introduction

_HelloID-Conn-Prov-Target-Powershell-Exchange-RemoteMailbox_ is a _target_ connector.   

This connector can create, hide and unhide Exchange online mailboxes through a hybrid Exchange server.

## Getting started

### Connection settings

The following settings are required to connect to the API.

| Setting      | Description                        | Mandatory   |
| ------------ | -----------                        | ----------- |
| Url      | The URL of the Exchange server              | Yes |
| username     | The UserName for Exchange access | Yes |
| password     | The Password for Exchange access | Yes |
| authenticationmode      | Authentication mode for Exchange access| Yes |
| remoteroutingaddress | Microsoft Online address e.g. 'company.mail.onmicrosoft.com'  | Yes |
| skipcacheck | Exchange option true/false  | No |
| skipcncheck | Exchange option true/false  | No |
| skiprevocationcheck | Exchange option true/false  | No |

### Prerequisites
* Exchange Hybrid Server

### Provisioning

Create:
* Set-RemoteMailbox for existing AD user  

Enable:
*  Unhides mailbox from addresslist

Disable:
*  Hides mailbox from addresslist

### Remarks
 
## Setup the connector

Import the config and provide the correct values and settings to connect to the Exchange server.

## HelloID docs

The official HelloID documentation can be found at: https://docs.helloid.com/

## Forum Thread
The Forum thread for any questions or remarks regarding this connector can be found at: [HelloID-Conn-Prov-Target-Powershell-Exchange-RemoteMailbox](https://forum.helloid.com/forum/helloid-connectors/provisioning/749-helloid-prov-target-exchange-remote-mailbox)
