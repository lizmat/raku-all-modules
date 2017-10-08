#!/usr/bin/env perl6
use lib 't/lib';
use HTTP::Server::Router::YAML;
use HTTP::Server::Async;
use Test;

my $s = HTTP::Server::Async.new;

serve $s;
route-yaml 't/data/route1.yaml';

$s.listen;

sub req (Str $req) {
  my IO::Socket::INET $client .=new(:host<127.0.0.1>, :port(1666));
  my $data                     = '';
  $client.print($req);
  sleep .5;
  while my $d = $client.recv {
    $data ~= $d;
  }
  CATCH { default { } }
  try { $client.close; CATCH { default { } } }
  return $data;
}

plan 5;

my @controllers = 'Whatever::&whatever', 'Whatever::&test', 'Whatever::Sub::&test', 'Whatever::Sub::&yolo';

my $i = 0;

ok req("GET /test{$i++} HTTP/1.0\r\nContent-length: 0\r\n\r\n").index($_), "$_"
  for @controllers;
ok req("GET /test{$i++} HTTP/1.0\r\nContent-length: 0\r\n\r\n").index('no route found'), "no route";

# vi:syntax=perl6
