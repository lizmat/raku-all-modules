# Net::OSC

A perl6 implementation of the Open Sound Control Protocol.

## status
very *WIP*
v0.001

## Overview
Net::OSC is currently planned to consist of the following classes:
* Net::OSC
* Net::OSC::Message
* Net::OSC::Bundle
* Net::OSC::Client
* Net::OSC::Server

Net::OSC provides message routing behaviors for the OSC Protocol, an OSC address space, while Net::OSC::Message and Net::OSC::Bundle provide a representation of the data. The Client and Server objects then provide higher level abstractions for the underlying OSC standard.

## Features
* Basic Net::OSC::Message implementation partly finished.
  * Unpackages messages containing the following OSC types:
    * i - a 32bit signed integer
    * s - an ascii string (This seems to work but there may be problems I haven't found here with perl6 unicode...)
    * d - Double precision floating point value (IEE754 - binary64)
    * f - single precision floating point value (IEE754 - binary32)
  * Packages messages, maps perl6 types as:
    * Str - s - encoded as 'ISO-8859-1'
    * Int - i - int32 (we still need some more intelligence here to handle larger values)
    * if is64bit switch is True
      * Rat - d
    * else
      * Rat - f
  * OSC path, make sure it starts with a '/' as the spec says! (Maybe this should be relaxed...)

## To Do
* Net::OSC::Message pack and unpack methods
* Net::OSC
* Net::OSC::Bundle
* Net::OSC::Client
* Net::OSC::Server
* More code examples!
* More tests...
* A native message packing and unpacking implementation amd/or bindings

## Examples
Have a look at the examples folder for some basic udp sender and receiver examples :D
