#!/usr/bin/env perl6

use v6.c;

use Test;

use Test::Deeply::Relaxed :DEFAULT, :test;

plan 2;

lives-ok { try die 'foo'; test-deeply-relaxed 1, $!, :!cache };
lives-ok { test-deeply-relaxed 1, (1, 2, 3...*), :!cache };
