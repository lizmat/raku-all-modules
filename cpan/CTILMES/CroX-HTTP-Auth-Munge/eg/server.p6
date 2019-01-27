#!/usr/bin/env perl6

use Cro::HTTP::Server;
use Cro::HTTP::Router;
use CroX::HTTP::Auth::Munge;

my Cro::Service $service = Cro::HTTP::Server.new:
    host => 'localhost', port => 10000,
    application => route
{
    before CroX::HTTP::Auth::Munge[CroX::HTTP::Auth::Munge::Session].new;

    get -> CroX::HTTP::Auth::Munge::Session $session {
        content 'text/plain', qq:to/END/;
        uid = $session.uid()
        gid = $session.gid()
        encode time = $session.encode-time()
        encodehost = $session.munge.addr4()
        ttl = $session.munge.ttl()
        ciper = $session.munge.cipher()
        payload = '$session.payload()'
        json = $session.json.gist()
        END
    }
};

say "Listening on http://localhost:10000";

$service.start;

react whenever signal(SIGINT)
{
    $service.stop;
    exit;
}
