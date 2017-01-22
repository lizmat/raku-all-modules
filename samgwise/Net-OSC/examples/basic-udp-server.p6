#! /usr/bin/env perl6

#
# This example shows a simple UDP server.
#  The approach here does not utilise the structure of the Net::OSC::Server role.
#

use v6;
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
$server.send: '/hello/not-really';
$server.send: '/hello', :args('world', );
$server.send: '/hello', :args('lamp', );
$server.send: '/hello';

# Send a message to someone else?
$server.send: '/hello', :args('out there', ), :address<192.168.1.1>, :port(54321);

#Allow some time for our messages to arrive
sleep 0.5;

# Give our server a chance to say good bye if it needs too.
$server.close;
