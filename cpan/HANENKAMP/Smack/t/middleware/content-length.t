#!/usr/bin/env perl6
use v6;

use Smack::Client::Request::Common;
use Smack::Middleware::ContentLength;
use Smack::Test;
use Test;
use HTTP::Status;

my @tests =
    {
        app     => -> %env { [ 200, [ Content-Type => 'text/plain' ], [ 'OK' ] ] },
        headers => [ Content-Type => 'text/plain', Content-Length => 2 ],
    },
    {
        app => -> %env {
            my $fh = "share/baybridge.jpg".IO.open(:bin).Supply;
            [ 200, [ Content-Type => 'image/jpeg' ], $fh ];
        },
        headers => [ 'Content-Type' => 'image/jpeg', 'Content-Length' => 14750 ],
    },
    {
        app => -> %env {
            [ 304, [ ETag => 'Foo' ], [] ];
        },
        headers => [ ETag => 'Foo' ],
    },
    {
        app => -> %env {
            my @body = "Hello World";
            [ 200, [ 'Content-Type' => 'text/plain' ], @body.Supply ];
        },
        headers => [ 'Content-Type' => 'text/plain' ],
    },
    {
        app => -> %env {
            [ 200, [ 'Content-Type' => 'text/plain', 'Content-Length' => 11 ], [ "Hello World" ] ];
        },
        headers => [ 'Content-Type' => 'text/plain', 'Content-Length' => 11 ],
    },
    ;

for @tests -> %test {
    my $handler = Smack::Middleware::ContentLength.new(
        app => sub (%env) { start { %test<app>(%env) } },
    );

    test-p6wapi $handler, -> $c {
        my $res = await $c.request(GET '/');
        diag "ERROR: $res.content()" if is-error($res.code);
        for @(%test<headers>) {
            is $res.header(.key), .value, "header {.key} is as expected";
        }
    };
}

done-testing;
