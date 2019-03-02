#!/usr/bin/env perl6
use v6;

use Smack::Builder;
use Test;

my $app := builder {
    mount "/" => -> %env {
        start {
            200, [ Content-Type => 'text/plain' ], [ 'Hello' ]
        }
    }
}

cmp-ok $app, '~~', Callable:D, 'app is callable';

done-testing;
