#! /usr/bin/env perl6

#
# This example shows a simple strategy for listening for messages.
#  The approach here does not utilise the structure of the Net::OSC::Server role.
#

use v6;
use Net::OSC::Message;

my Net::OSC::Message $osc-message .= new;

my $udp-listener = IO::Socket::Async.bind-udp('localhost', 7654);
my $listener-cb = $udp-listener.Supply(:bin).tap: -> $buf {
  if $buf.elems > 0 {
    my $message = $osc-message.unpackage($buf);
    say "message: { $message.path, $message.type-string, $message.args }";
  }
  #else empty packet
}

#hang around for a message
while True {
  sleep 1
}

#catch control-c
signal(SIGINT).tap: -> {
  $listener-cb.close if $listener-cb;
  exit 0;
}

$listener-cb.close;
