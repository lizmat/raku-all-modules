[![Build Status](https://travis-ci.org/samgwise/Net-OSC.svg?branch=master)](https://travis-ci.org/samgwise/Net-OSC)

NAME
====

Net::OSC - Open Sound Control for Perl6

Currently Net::OSC::Message is implimented You can use it right now to send and receive OSC messages!

SYNOPSIS
========

    use Net::OSC::Message;

    #Create a message object to unpack OSC Bufs
    my Net::OSC::Message $osc-message .= new;

    #Create a UDP listener
    my $udp-listener = IO::Socket::Async.bind-udp('localhost', 7654);

    #tap our udp supply and grep out any empty packets
    my $listener-cb = $udp-listener.Supply(:bin).grep( *.elems > 0 ).tap: -> $buf {
      my $message = $osc-message.unpackage($buf);
      say "message: { $message.path, $message.type-string, $message.args }";
    }

    #Start up a thread so we can send some OSC messages to ourself
    my $sender = start {
      my $udp-sender = IO::Socket::Async.udp;

      for 1..10 {
        my Net::OSC::Message $message .= new( :path("/testing/$_") :args<Hey 123 45.67> );

        #send it off
        my $sending = $udp-sender.write-to('localhost', 7654, $message.package);
        await $sending;
        sleep 0.5;
      }
      sleep 1;
    }

    await $sender;

    $listener-cb.close;

DESCRIPTION
===========

Net::OSC is currently planned to consist of the following classes:

  * Net::OSC

  * Net::OSC::Message - Implimented

  * Net::OSC::Bundle

  * Net::OSC::Client

  * Net::OSC::Server

Net::OSC provides message routing behaviors for the OSC Protocol, an OSC address space. Net::OSC::Message and Net::OSC::Bundle provide a representation and packaing of the data. The Client and Server objects then provide higher level abstractions for network comunication.

For more details about each class, see their doc.

TODO
====

  * Net::OSC::Bundle

  * Net::OSC::Client

  * Net::OSC::Server

  * Additional OSC types

  * Net::OSC - A simple interface for OSC comunications

CHANGES
=======

<table>
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
