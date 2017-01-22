[![Build Status](https://travis-ci.org/samgwise/Net-OSC.svg?branch=master)](https://travis-ci.org/samgwise/Net-OSC)
NAME
====

Net::OSC - Open Sound Control for Perl6

Use the Net::OSC module to communicate with OSC applications and devices!

SYNOPSIS
========

```perl6
use Net::OSC;

my Net::OSC::Server::UDP $server .= new(
  :listening-address<localhost>
  :listening-port(7658)
  :send-to-address<localhost> # ← Optional but makes sending to a single host very easy!
  :send-to-port(7658)         # ↲
  :actions(
    action(
      "/hello",
      sub ($msg, $match) {
        if $msg.type-string eq 's' {
          say "Hello { $msg.args[0] }!";
        }
        else {
          say "Hello?";
        }
      }
    ),
  )
);

# Send some messages!
$server.send: '/hello', :args('world', );
$server.send: '/hello', :args('lamp', );
$server.send: '/hello';

# Our routing will ignore this message:
$server.send: '/hello/not-really';

# Send a message to someone else?
$server.send: '/hello', :args('out there', ), :address<192.168.1.1>, :port(54321);

#Allow some time for our messages to arrive
sleep 0.5;

# Give our server a chance to say good bye if it needs too.
$server.close;
```

DESCRIPTION
===========

Net::OSC distribution currently provides the following classes:

  * Net::OSC

  * Net::OSC::Message

  * Net::OSC::Server

  * Net::OSC::Server::UDP

Classes planned for future releases include:

  * Net::OSC::Bundle

  * Net::OSC::Server::TCP

Net::OSC imports Net::OSC::Server::UDP and the action sub to the using name space. Net::OSC::Message provide a representation for osc messages.

See reference section below for usage details.

TODO
====

  * Net::OSC::Bundle

  * Net::OSC::Server::TCP

  * Additional OSC types

CHANGES
=======

<table>
  <tr>
    <td>Added Server role and UDP server</td>
    <td>Sugar for sending, receiving and routing messages</td>
    <td>2016-12-08</td>
  </tr>
  <tr>
    <td>Updated to use Numeric::Pack</td>
    <td>Faster and better tested Buf packing</td>
    <td>2016-08-30</td>
  </tr>
</table>

AUTHOR
======

Sam Gillespie <samgwise@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Reference
=========

Net::OSC subroutines 
---------------------

### sub action

```
sub action(
    Regex $path, 
    Callable $call-back
) returns Net::OSC::Types::EXPORT::DEFAULT::ActionTuple
```

Creates an action tuple for use in a server's actions list. The first argument is the path, which is checked when an OSC message is received. If the path of the message matches then the call back is executed. The call back is passed the Net::OSC::Message object and the match object from the regular expression comparison.

### sub action

```
sub action(
    Str $path where { ... }, 
    Callable $call-back
) returns Net::OSC::Types::EXPORT::DEFAULT::ActionTuple
```

Creates an action tuple for use in a server's actions list. The string must be a valid OSC path (currently we only check for a beginning '/' character). In the future this subroutine may translate OSC path meta characters to Perl6 regular expressions.
NAME
====

Net::OSC::Message - Implements OSC message packing and unpacking

METHODS
=======

```
method new(:$path = '/', :@args, :$!is64bit = True)
```

Set :is64bit to false to force messages to be packed to 32bit types this option may be required to talk to some versions of Max and other old OSC implementations.

### method type-string

```
method type-string() returns Str
```

Returns the current type string of this messages content. See OSC types for possible values.

### method pick-osc-type

```
method pick-osc-type(
    $arg
) returns Str
```

Returns the character representing the OSC type $arg would be packed as by this Message object.

### method args

```
method args(
    *@new-args
) returns Seq
```

Adds any arguments as args to the object and returns the current message arguments. The OSC type of the argument will be determined according the the current OSC types map.

### method set-args

```
method set-args(
    *@new-args
) returns Mu
```

Clears the message args lists and sets it to the arguments provided. The OSC type of the argument will be determined according the the current OSC types map.

### method type-map

```
method type-map() returns Seq
```

Returns the current OSC type map of the message. This will change depending on the is64bit flag.

### method package

```
method package() returns Blob
```

Returns a Buf of the packed OSC message. See unpackage to turn a Buf into a Message object.

### method unpackage

```
method unpackage(
    Buf $packed-osc
) returns Net::OSC::Message
```

Returns an Net::OSC::Message from a Buf where the content of the Buf is an OSC message. Will die on unhandled OSC type and behaviour is currently undefined on non OSC message Bufs.
NAME
====

Net::OSC::Server - A role to facilitate a convenient platform for OSC communication.

METHODS
=======

```
method new(:$!is64bit = True)
```

Set :is64bit to false to force messages to be packed to 32bit types this option may be required to talk to some versions of Max and other old OSC implementations.

### method actions

```
method actions() returns Seq
```

Lists the actions managed by this server. Actions are expressed as a list holding a Regex and a Callable object. Upon receiving a message the server tries to match the path of the OSC message with the Regex of an action. All actions with a matching Regex will be executed. the Callable element of an action is called with a Net::OSC::Message and a Match object.

### method add-action

```
method add-action(
    Regex $path, 
    Callable $action
) returns Mu
```

Add an action for managing messages to the server. See the actions method description above for details and the add-actions method below for the plural expression.

### method add-actions

```
method add-actions(
    *@actions
) returns Mu
```

Add multiple actions for managing messages to the server. See the actions method description above for details.

### method send

```
method send(
    Str $path where { ... }, 
    *%params
) returns Mu
```

Send and OSC message. The to add arguments to the message pass :args(...), after the OSC path string. Implementing classes of the Server role may accept additional named parameters.

### method close

```
method close() returns Mu
```

Call the server's on-close method. This will call the server implementations on-close hook.

### method transmit-message

```
method transmit-message(
    Net::OSC::Message:D $message
) returns Mu
```

Transmit an OSC message. This method must be implemented by consuming classes. implementations may add additional signatures. Use this method to send a specific OSC message object instead of send (which creates one for you).
NAME
====

Net::OSC::Server::UDP - A convenient platform for OSC communication over UDP.

```
Does Net::OSC::Server - look there for additional methods.
```

METHODS
=======

```
method new(
  Bool :$!is64bit = True,
  Str :listening-address,
  Int :listening-port,
  Str :send-to-address,
  Int :send-to-port,
)
```

Set :is64bit to false to force messages to be packed to 32bit types this option may be required to talk to some versions of Max and other old OSC implementations. The send-to-* parameters are not required but allow for convenient semantics if you are only communicating with a single host.

### method send

```
method send(
    Str $path where { ... }, 
    *%params
) returns Mu
```

Send a UDP message to a specific host and port. This method extends the Net::OSC::Server version and adds the :address and :port Named arguments to support UDP message sending. If :address or :port are not provided the Server's relevant send-to-* attribute will be used instead.

### method transmit-message

```
method transmit-message(
    Net::OSC::Message:D $message
) returns Mu
```

Transmit an OSC message. This implementation will send the provided message to the server's send-to-* attributes.

### method transmit-message

```
method transmit-message(
    Net::OSC::Message:D $message, 
    Str $address, 
    Int $port
) returns Mu
```

Transmit an OSC message to a specified host and port. This implementation sends the provided message to the specified address and port.
