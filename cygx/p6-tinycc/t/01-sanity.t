#!/usr/bin/env perl6

use v6;

use Test;
use TinyCC *;

plan 1;

tcc.compile('void dummy(void) {}').relocate;
pass 'still alive after relocation';

done-testing;
