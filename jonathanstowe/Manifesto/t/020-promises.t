#!/usr/bin/env perl6

use v6.c;

use Test;
use Manifesto;

my $manifesto;

lives-ok { $manifesto = Manifesto.new }, "create the Manifesto object";

isa-ok $manifesto, Manifesto, "got the right thing";

my Str $result = "no result";

my $guard = Promise.new;

lives-ok {
    $manifesto.Supply.tap( -> $v {
        $result = $v;
        $guard.keep: "ok";
    });
}, "tap the supply";

my Bool $empty = False;

lives-ok {
    $manifesto.empty.tap({ $empty = True });
}, "tap the empty supply";


my $promise = Promise.new;

ok $manifesto.add-promise($promise), "add the Promise";

is $manifesto.promises.elems, 1, "got the promise";

$promise.keep: "what we expected";

await Promise.anyof($guard, Promise.in(1));

is $result, "what we expected", "the tap got fired";
is $manifesto.promises.elems, 0, "the promise went away";
ok $empty, "and the empty supply got fired";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
