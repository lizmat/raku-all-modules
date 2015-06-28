#!/usr/bin/env perl6

use HTTP::Server::Threaded;
use HTTP::Server::Router;
use Test;


start { 
  my HTTP::Server::Threaded $app .=new;

  serve $app;

  route '/:named/whatever', sub ($req, $res) {
    my $str = $req.params<named> // '';
    $res.close($str); 
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
  sub req ($req) {
    my IO::Socket::INET $client .=new(:host<127.0.0.1>, :port(8091));
    my $data                     = '';
    $client.send($req);
    sleep .5;
    while my $d = $client.recv {
      $data ~= $d;
    }
    CATCH { default { .say; } }
    try { $client.close; CATCH { default { .say; } } };
    return $data;
  }


  ok req("GET /poboy HTTP/1.0\r\nContent-length: 0\r\n\r\n") ~~ /'pass' $/, 'Pass test';
  ok req("GET /poboy/whatever HTTP/1.0\r\nContent-length: 0\r\n\r\n") ~~ /'poboy' $/, 'Parsed param \'named\' => \'poboy\'';
  ok req("GET /aabcc HTTP/1.0\r\nContent-length: 0\r\n\r\n") ~~ /'/.+/' $/, '/.+/ regex match';
}

# vi:syntax=perl6
