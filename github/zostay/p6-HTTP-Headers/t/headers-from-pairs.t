#!perl6

use v6;

use Test;
use HTTP::Headers;

{
    my @headers =
        ::(Content-Type)   => 'text/plain',
        ::(Content-Length) => 42,
        X-Foo-Bar          => 'baz',
        ;

    my $h = HTTP::Headers.new(@headers);

    is $h.Content-Type, 'text/plain', 'Content-Type';
    is $h.Content-Length, 42, 'Content-Length';
    is $h.header('X-Foo-Bar'), 'baz', 'X-Foo-Bar';

    $h.headers:
        ::(Content-Type) => 'text/html',
        ::(Allow)        => 'GET',
        ::(Allow)        => 'POST',
        ;

    is $h.Content-Type, 'text/html', 'Content-Type still ok';
    is $h.Allow.value, 'GET, POST', 'Allow';
}

{
    my %headers =
        ::(Content-Type)   => 'text/plain',
        ::(Content-Length) => 42,
        X-Foo-Bar          => 'baz',
        ;

    my $h = HTTP::Headers.new(%headers);

    is $h.Content-Type, 'text/plain', 'Content-Type';
    is $h.Content-Length, 42, 'Content-Length';
    is $h.header('X-Foo-Bar'), 'baz', 'X-Foo-Bar';

    my @headers =
        ::(Content-Type) => 'text/html',
        ::(Allow)        => 'GET',
        ::(Allow)        => 'POST',
        ;

    $h.headers(@headers);

    is $h.Content-Type, 'text/html', 'Content-Type still ok';
    is $h.Allow.value, 'GET, POST', 'Allow';
}

{
    my $h = HTTP::Headers.new:
        ::(Content-Type)   => 'text/plain',
        ::(Content-Length) => 42,
        X-Foo-Bar          => 'baz',
        ;

    is $h.Content-Type, 'text/plain', 'Content-Type';
    is $h.Content-Length, 42, 'Content-Length';
    is $h.header('X-Foo-Bar'), 'baz', 'X-Foo-Bar';

    my %headers =
        ::(Content-Type) => 'text/html',
        ::(Allow)        => 'GET',
        ::(Allow)        => 'POST',
        ;

    $h.headers(%headers);

    is $h.Content-Type, 'text/html', 'Content-Type still ok';
    is $h.Allow.value, 'POST', 'Allow';
}

done-testing;
