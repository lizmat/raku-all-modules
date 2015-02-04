#!/usr/bin/env perl6

use lib 't/lib';
use lib 'lib';
use starter;
use HTTP::Server::Async::Plugins::Router::Simple;
use Test;
plan 7;

my $host = host;
my $port = port;
my $rest = HTTP::Server::Async::Plugins::Router::Simple.new;
my $serv = srv;
my $ord  = 0;

$rest.put(
  / ^ '/' $ / => sub ($q, $s, $c) {
    $ord = 100; # this will never get called
    $c();
  }
);

$rest.all(
  / ^ '/' $ / => sub ($req, $res, $cb) {
    ok True, 'Matched first in chain' if $ord++ == 0;
    $cb(True);
  },
  '/' => sub ($req, $res, $cb) {
    ok True, 'Matched second in chain' if $ord++ == 1;
    start {
      sleep 3;
      ok True, 'Waited for sleep before matching next' if $ord++ == 2;
      $cb(True);
    };
  },
  '/' => sub ($req, $res, $cb) {
    ok True, 'Waited for sleep before matching next (2)' if $ord++ == 3;
    $res.close("Hi world\n");
  },
  '/' => sub ($req, $res, $cb) {
    ok False, 'This should never be called';
  },
);

$rest.hook($serv);

$serv.register(sub ($req, $res, $cb) {
 ok True, 'this should be called only if req<uri> == \'/404\'' if $req.uri eq '/404'; 
 $res.close('done');
});

$serv.listen;
my $client = req;
$client.send("GET / HTTP/1.0\r\n\r\n");
my $ret;
while (my $str = $client.recv) {
  $ret ~= $str;
}
$client.close;
ok $ret.match(/ ^^ 'Hi world' $$/), 'Got to the end';
ok $ord == 4, 'Never called last sub';

$client = req;
$client.send("GET /404 HTTP/1.0\r\n\r\n");
$ret = '';
while ($str = $client.recv) {
  $ret ~= $str;
}
$client.close;
