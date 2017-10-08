#!/usr/bin/env perl6

use v6.c;
use LWP::Simple;

use Test;
plan 1;

try require IO::Socket::SSL;
if $! {
    skip-rest("IO::Socket::SSL not available");
    exit 0;
}

if %*ENV<NO_NETWORK_TESTING> {
    diag "NO_NETWORK_TESTING was set";
    skip-rest("NO_NETWORK_TESTING was set");
    exit;
}

lives-ok {
    LWP::Simple.get("http://github.com/");
}, "can retrieve http://github.com/";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
