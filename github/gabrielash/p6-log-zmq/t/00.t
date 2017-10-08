#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

plan 1;

say "testing packages";

#use-ok 'Log::ZMQ::Logger.pm';
#use-ok 'Log::ZMQ::LogCatcher.pm';

use Log::ZMQ::LogCatcher;
use Log::ZMQ::Logger;

pass "why does use-ok fail with confused? ";

done-testing;
