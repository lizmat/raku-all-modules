#! /usr/bin/env per6
use v6;
use Test;

plan 5;

use-ok 'Net::OSC::Server::UDP';
use Net::OSC::Server::UDP;

my $address = 'localhost';
my $port = 7654;

# Note no action subroutine sugar around the action tuple
my Net::OSC::Server::UDP $server .= new(
  :actions(
    $(
      regex { ^ '/' test $ },
      sub ($message, $match) {
        is $message.path, '/test', "Message path matches";
        is $message.args, (1, ), "Message arg is 1";
      }
    ),
    $(
      regex { ^ '/' test '/' to '-' address $ },
      sub ($message, $match) {
        is $message.path, '/test/to-address', "Message path matches";
        is $message.args, (2, ), "Message arg is 2";
      }
    )
  )
  :listening-address($address)
  :listening-port($port)
  :send-to-address($address)
  :send-to-port($port)
);

# Should not execute action, no tests executed
$server.send("/not-test", :args<foo bar>);
$server.send("/also/not-test");
$server.send("/not-test/to-address", :args<foo bar>, :$address, :$port);
$server.send("/also/not-test/to-address", :$address, :$port);

# Should execute action and pass tests
$server.send("/test", :args(1, ));
$server.send("/test/to-address", :args(2, ), :$address, :$port);

sleep 0.5;

$server.close;
