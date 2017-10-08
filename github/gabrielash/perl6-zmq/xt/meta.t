#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Test::META;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

plan 1;


meta-ok;

done-testing;
