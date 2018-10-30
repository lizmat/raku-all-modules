#!/usr/bin/env perl6

use v6.c;

use Test;
use Unicode::GCB;

plan 4;

my \RI_G = '\c[REGIONAL INDICATOR SYMBOL LETTER G]';
my \RI_B = '\c[REGIONAL INDICATOR SYMBOL LETTER B]';

ok not GCB.always(0x600, 0x30);
ok so GCB.maybe(RI_G.ord, RI_B.ord);
ok GCB.clusters("äöü".NFD) == 3;
ok GCB.clusters("\r\n".NFD) == 1;
