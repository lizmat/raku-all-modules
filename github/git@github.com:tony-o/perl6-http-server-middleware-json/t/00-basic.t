#!/usr/bin/env perl6

use HTTP::Server::Async;
use HTTP::Server::Middleware::JSON;
use JSON::Fast;
use Test;

plan 5;

my HTTP::Server::Async $app .=new;

body-parse-json $app;

$app.handler: sub ($req, $res) {
  return $res.close('not parsed')
   unless $req.params<stash><body-parsed>:exists;
  True;
};

$app.handler: sub ($req, $res) is json-consumer {
  if $req.params<stash><body-parsed> {
    $res.close(to-json($req.params<body>));
    return False;
  }
  True;
};

$app.listen;

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

my @jsons = to-json({ a => 1, b => 2, }), to-json({ xyz => 123 }), 'hi';

ok req("GET / HTTP/1.0\r\nContent-length: 0\r\n\r\n") ~~ /'not parsed' $/, 'Not parsed';
ok req("GET / HTTP/1.0\r\nContent-length: {@jsons[0].chars}\r\nContent-Type: application/json\r\n\r\n{@jsons[0]}") ~~ / {@jsons[0]} /, 'Parsed and returned: '~@jsons[0].perl;
ok req("GET / HTTP/1.0\r\nContent-length: {@jsons[1].chars}\r\nContent-Type: application/json\r\n\r\n{@jsons[1]}") ~~ / {@jsons[1]} /, 'Parsed and returned: '~@jsons[1].perl;

ok req("GET / HTTP/1.0\r\nContent-length: {@jsons[2].chars}\r\nContent-Type: application/json\r\n\r\n{@jsons[2]}") ~~ / 'invalid json' /, 'Attempt parse and fail with default error handler';

json-error sub ($req, $res) {
  $res.close('custom invalid json err');
  False;
};

ok req("GET / HTTP/1.0\r\nContent-length: {@jsons[2].chars}\r\nContent-Type: application/json\r\n\r\n{@jsons[2]}") ~~ / 'custom invalid json err' /, 'Attempt parse and fail with custom error handler';

# vi:syntax=perl6
