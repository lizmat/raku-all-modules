#!/usr/bin/env perl6

use lib 't/lib';
use starter;
use Test;

plan 2;

my $s = srv;

my Str $timetest = time.Str;
$s.middleware(sub ($req, $res){
  $res.headers<XYZ> = 'ABC';  
  return True;
});
$s.handler(sub ($req,$res) {
  $res.headers<Connection> = 'close';
  $res.close($timetest);
});

start {
  sleep 1;
  my $client = req;

  $client.print("GET / HTTP/1.0\r\n\r\n");
  my $data;
  while (my $str = $client.recv) {
    $data ~= $str;
  }
  $client.close;

  ok $data ~~ rx/^^ 'XYZ: ABC' $$/, 'Testing for XYZ Middleware Header';
  ok $data ~~ rx/^^ "$timetest" $$/, "Testing for $timetest";

  exit 0;
}

$s.listen;
# vi:syntax=perl6
