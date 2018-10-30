#!/usr/bin/env perl6

use v6.c;

use Test;
use HTTP::Parser;

my $test = "GET / HTTP/1.0\x[0d]\x[0a]User-Agent: a b c\x[0d]\x[0a]\x[0d]\x[0a]Hepæstus was a strange øld þing";

# by default it would give a utf8 buf which subsequently
# won't be decoded.
my $buf = Buf.new($test.encode.list);

# don't need to check the whole thing
lives-ok {
    my ($retval, $env) = parse-http-request($buf);
    ok $retval, "got retval";
    is $env<REQUEST_METHOD>, 'GET', "got the right REQUEST METHOD";
    is $env<HTTP_USER_AGENT>, 'a b c', "and the user agent string";

}, "can parse one with a unicode body";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
