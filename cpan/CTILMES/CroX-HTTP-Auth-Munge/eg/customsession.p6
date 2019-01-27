#!/usr/bin/env perl6

use Cro::HTTP::Server;
use Cro::HTTP::Router;
use CroX::HTTP::Auth::Munge;

class MySession does CroX::HTTP::Auth::Munge::Session
{
    method a { $.json<a> }
    method b { $.json<b> }
}

class MyAuth does CroX::HTTP::Auth::Munge[MySession] {}

my Cro::Service $service = Cro::HTTP::Server.new:
    host => 'localhost', port => 10000,
    application => route
{
    before MyAuth.new;

    get -> MySession $session {
        content 'text/plain', qq:to/END/;
        uid = $session.uid()
        a = $session.a()
        b = $session.b()
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
