#!/usr/bin/env perl6

use v6.c;

use Test;

plan 1;

use Manifesto;

my $manifesto = Manifesto.new;

for (^10).pick(*).map( -> $i { Promise.in($i + 0.5).then({ $i })}) -> $p {
    $manifesto.add-promise($p);
}

my $channel = Channel.new;

react {
    whenever $manifesto -> $v {
        $channel.send: $v;
    }
    whenever $manifesto.empty {
        $channel.close;
        done;
    }
}

is-deeply $channel.list, (^10).list, "got what we expected";

# vim: expandtab shiftwidth=4 ft=perl6
