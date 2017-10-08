#!/usr/bin/env perl6

use v6;

use Test;
use Uni63;

plan 5;

my \IN1 = 'Leberkäse';

my $enc = Uni63::enc(IN1);
ok so $enc ~~ / ^ <[0..9a..zA..Z_]>+ $ /, "encode { IN1 }";
ok $enc.comb(/_/) == 1, 'count escapes';

my $dec = Uni63::dec($enc);
is $dec, IN1, "decode $enc";

my \IN2 = q:to/__END__/;
    Over hill, over dale,
    Thorough bush, thorough brier,
    Over park, over pale,
    Thorough flood, thorough fire,
    I do wander everywhere.
    __END__

is Uni63::dec(Uni63::enc(IN2)), IN2, 'round trip Shakespeare';
is Uni63::dec(Uni63::dec(Uni63::enc(Uni63::enc(IN2)))), IN2,
    'iterated round trip';
