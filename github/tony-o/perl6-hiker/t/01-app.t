#!/usr/bin/env perl6

use Test;
use Hiker;

plan 2;

chdir 't';

my $app = Hiker.new(
  hikes     => ['controllers', 'models'],
  templates => 'templates',
  :port(8666),
);


$app.listen;

sub req(Str $req) {
   my IO::Socket::INET $client .=new(:host<127.0.0.1>, :port(8666));
   my $data                     = '';
   $client.print($req);
   sleep .5;
   while my $d = $client.recv {
     $data ~= $d;
   }
   CATCH { default { "CAUGHT {$_}".say; } }
   try { $client.close; CATCH { default { } } }
   return $data;
}

ok req("GET / HTTP/1.0\r\nContent-length: 0\r\n\r\n") ~~ /'Hello, WOT?!' \s* $/, 'Hello, WOT?!';
ok req("GET /404 HTTP/1.0\r\nContent-length: 0\r\n\r\n") ~~ /'404 - page not found.' \s* $/, '404 - page not found.';

chdir '..';

# vi:syntax=perl6
