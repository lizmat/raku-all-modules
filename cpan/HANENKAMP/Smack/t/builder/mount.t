#!/usr/bin/env perl6
use v6;

use Smack::Builder;
use Test;

throws-like {
    builder {
        mount "/" => -> %env { };
        -> %env { };
    }
}, X::Smack::Builder::UselessMount;

lives-ok {
    CATCH { when X::Smack::Builder::UselessMount { .resume } }

    my $app := builder {

        mount "/" => -> %env { };
        -> %env { };
    }

    cmp-ok $app, '~~', Callable:D, 'app is callable';
}

done-testing;
