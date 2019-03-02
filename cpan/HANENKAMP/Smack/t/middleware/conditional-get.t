#!/usr/bin/env perl6
use v6;

use Smack::Client::Request::Common;
use HTTP::Status;
use Smack::Middleware::ConditionalGET;
use Smack::Test;
use Test;

my $tag  = "Foo";
my $date = "Wed, 23 Sep 2009 13:36:33 GMT";
my $non-matching-date = "Wed, 23 Sep 2009 13:36:32 GMT";

my @tests =
    {
        name    => 'no conditional headers',
        app     => ( 200, [ Content-Type => 'text/plain' ], [ 'OK' ] ),
        request => GET('/'),
        status  => 200,
        headers => [ Content-Type => 'text/plain' ],
    },
    {
        name    => 'etag header triggers not modified',
        app     => ( 200, [ ETag => $tag, Content-Type => 'text/plain' ], [ 'OK' ] ),
        request => GET('/', If-None-Match => $tag),
        status  => 304,
        headers => [ ETag => $tag ],
    },
    {
        name    => 'date header triggers not modified',
        app     => ( 200, [ Last-Modified => $date, Content-Type => 'text/plain' ], [ 'OK' ] ),
        request => GET('/', If-Modified-Since => $date),
        status  => 304,
        headers => [ "Last-Modified" => $date ],
    },
    {
        name    => 'date header does not trigger not modified',
        app     => ( 200, [ Last-Modified => $date, Content-Type => 'text/plain' ], [ 'OK' ] ),
        request => GET('/', If-Modified-Since => $non-matching-date),
        status  => 200,
        headers => [
            Last-Modified => $date, Content-Type => "text/plain",
        ],
    },
    {
        name    => 'date header with length triggers not modified',
        app     => ( 200, [ Last-Modified => $date, Content-Type => 'text/plain' ], [ 'OK' ] ),
        request => GET('/', If-Modified-Since => "$date; length=2"),
        status  => 304,
        headers => [ "Last-Modified" => $date ],
    },
    {
        name    => 'etag header does not trigger not modified for POST',
        app     => ( 200, [ ETag => $tag, Content-Type => 'text/plain' ], [ 'OK' ] ),
        request => POST('/', content => '', If-None-Match => $tag),
        status  => 200,
        headers => [ ETag => $tag, 'Content-Type' => "text/plain" ],
    },
    {
        name    => 'etag and date header triggers not modified',
        app     => ( 200, [ ETag => $tag, Last-Modified => $date, Content-Type => 'text/plain' ], [ 'OK' ] ),
        request => GET('/', If-None-Match => $tag, If-Modified-Since => $date),
        status  => 304,
        headers => [ ETag => $tag, 'Last-Modified' => $date ],
    },
    {
        name    => 'etag and date header does not trigger not modified because of tag mismatch',
        app     => ( 200, [ ETag => $tag, Last-Modified => $date, Content-Type => 'text/plain' ], [ 'OK' ] ),
        request => GET('/', If-None-Match => 'Bar', If-Modified-Since => $date),
        status  => 200,
        headers => [ ETag => $tag, 'Last-Modified' => $date, 'Content-Type' => 'text/plain' ],
    },
    {
        name    => 'etag and date header does not trigger not modified because of date mismatch',
        app     => ( 200, [ ETag => $tag, Last-Modified => $date, Content-Type => 'text/plain' ], [ 'OK' ] ),
        request => GET('/', If-None-Match => $tag, If-Modified-since => $non-matching-date),
        status  => 200,
        headers => [ ETag => $tag,  'Last-Modified' => $date, 'Content-Type' => 'text/plain' ],
    },
    ;

for @tests -> %test {
    my $handler = Smack::Middleware::ConditionalGET.new(
        app => -> %env { start { %test<app> } }
    );

    test-p6wapi $handler, -> $c {
        subtest {
            my $res = await $c.request(%test<request>);
            diag "ERROR: $res.content()" if is-error($res.code);
            is $res.code, %test<status>, "status matches expected %test<status>";
            for @(%test<headers>) {
                is $res.header(.key), .value, "header {.key} matches expected value";
            }
            if $res.code == 304 {
                is $res.content, '', '304 response has empty entity';
            }
        }, %test<name>;
    };
}

done-testing;
