#! /usr/bin/env perl6
use v6;
use Test;

plan 3;

use-ok 'Net::OSC';
use Net::OSC;


my Net::OSC::Server::UDP $server .= new(
  :listening-address<localhost>
  :listening-port(7658)
  :send-to-address<localhost>
  :send-to-port(7658)
  :actions(
    action( regex { ^ '/' test $ }, sub ($m, $ ) { is $m.path, '/test', "Message recieved" } ),
    action( "/test/string",         sub ($m, $ ) { is $m.path, '/test/string', "Message recieved" } ),
  )
);

$server.send('/not-a-test');
$server.send('/test');
$server.send('/test/string');

sleep 0.5;
