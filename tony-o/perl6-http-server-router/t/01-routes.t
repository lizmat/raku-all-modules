#!/usr/bin/env perl6

use HTTP::Server::Threaded;
use HTTP::Server::Router;
use Test;

sub req ($req) {
  my IO::Socket::INET $client .=new(:host<127.0.0.1>, :port(8091));
  my $data                     = '';

  $client.send($req);
  while my $d = $client.recv {
    $data ~= $d;
  }
  try $client.close;
  return $data;
}

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
  $res.close('404');
}

start {
  $app.listen;
};

my IO::Socket::INET $client .=new(:host<127.0.0.1>, :port(8091));
my $data;

{
  $data = req("GET /poboy HTTP/1.0\r\nContent-length: 0\r\n\r\n");

  ok $data ~~ /'pass' $/, 'Pass test';
}

{
  $data = req("GET /poboy/whatever HTTP/1.0\r\nContent-length: 0\r\n\r\n");

  ok $data ~~ /'poboy' $/, 'Parsed param \'named\' => \'poboy\'';
}

{
  $data = req("GET /aabcc HTTP/1.0\r\nContent-length: 0\r\n\r\n");

  ok $data ~~ /'b' $/, 'b';
}
exit 0;

# vi:syntax=perl6
