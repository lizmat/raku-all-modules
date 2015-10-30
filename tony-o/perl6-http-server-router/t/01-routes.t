#!/usr/bin/env perl6

use HTTP::Server::Async;
use HTTP::Server::Router;
use Test;

plan 3;


start { 
  my HTTP::Server::Async $app .=new;

  serve $app;

  route '/:named/whatever', sub ($req, $res) {
    my $str = $req.params<named> // '';
    $res.perl.say;
    $res.close($str); 
    'here'.say;
  };

  route '/poboy', sub ($req, $res) {
    my $str = ($req.params<named> // '') eq 'poboy' ?? 'fail' !! 'pass';
    $res.close($str);
  };

  route /.+/, sub ($req, $res) {
    $res.close('/.+/');
  }
  $app.listen;
  CATCH { default { .say; } }
}
sleep 2;

await start {
  sub req (Str $req) {
    my IO::Socket::INET $client .=new(:host<127.0.0.1>, :port(1666));
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


  ok req("GET /poboy HTTP/1.0\r\nContent-length: 0\r\n\r\n") ~~ /'pass' $/, 'Pass test';
  ok req("GET /poboy/whatever HTTP/1.0\r\nContent-length: 0\r\n\r\n") ~~ /'poboy' $/, 'Parsed param \'named\' => \'poboy\'';
  ok req("GET /aabcc HTTP/1.0\r\nContent-length: 0\r\n\r\n") ~~ /'/.+/' $/, '/.+/ regex match';
}

# vi:syntax=perl6
