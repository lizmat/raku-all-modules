#!/usr/bin/env perl6

use lib 't/lib';
use lib 'lib';
use Pandapack;
use Test;

plan 1;

Pandapack.new.build;

ok 1, 'passed build phase';
