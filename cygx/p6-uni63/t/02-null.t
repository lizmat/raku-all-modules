#!/usr/bin/env perl6

use v6;

use Test;
use Uni63;

plan 4;

is Uni63::enc("\x00"), '_0', 'encode NUL';
is Uni63::dec('_0'), "\x00", 'decode encoded NUL';
is Uni63::dec(Uni63::enc("\x00")), "\x00", 'round trip NUL';
is Uni63::enc(Uni63::dec('_0')), '_0', 'round trip encoded NUL';
