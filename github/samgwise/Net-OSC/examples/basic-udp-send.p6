#! /usr/bin/env perl6

#
# This example shows a simple strategy for sending messages.
#  The approach here does not utilise the structure of the Net::OSC::Server role.
#

use v6;
use Net::OSC::Message;

# Create a UDP socket
my $udp-sender = IO::Socket::Async.udp;

# Create our message
my Net::OSC::Message $message .= new(
  :path</testing>
  :args(1, 2.3456789, 'abc')
  :is64bit(False)
);

# Write our message tp the socket.
# Note we call the .package Method to retrieve a binary Buf of our message
await $udp-sender.write-to('localhost', 7654, $message.package);
