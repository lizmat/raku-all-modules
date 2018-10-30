#!/usr/bin/env perl6

use Foo::Regressed::Very;
use Test;

plan 1;

ok foo, ‘returns True’;
