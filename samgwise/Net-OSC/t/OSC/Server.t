#! /usr/bin/env per6
use v6;
use Test;

plan 3;

use-ok 'Net::OSC::Server';
use Net::OSC::Server;

class TestServer does Net::OSC::Server {
  has Supplier  $!events;
  has Supply    $!in;
  has Tap       $!tap;

  submethod BUILD(:@actions) {
    self.add-actions(@actions);
    self!listen;
  }

  #= Start listening for OSC messages
  method !listen() {
    $!events = Supplier.new;
    $!in = $!events.Supply;
    $!tap = $!in.tap: -> $message { self!on-message-recieved($message) if defined $message }
  }

  #= Clean up listener and sender objects
  method !on-close {
    $!tap.close
  }

  #= Transmit an OSC message
  multi method transmit-message(Net::OSC::Message:D $message) {
    $!events.emit: $message
  }

}

# Note no action subroutine sugar around the action tuple
my TestServer $server .= new(
  :actions( $(regex { ^ '/' test $ }, sub ($message, $match) {
    is $message.path, '/test', "Message path matches";
    is $message.args, (1, ), "Message arg is 1";
  }), )
);

# Should not execute action, no tests executed
$server.send("/not-test", :args<foo bar>);
$server.send("/also/not-test");

# Should execute action and pass tests
$server.send("/test", :args(1, ));

sleep 0.5;

$server.close;
