#!/usr/bin/env perl6

use Foo::Dependencies::B-on-A;
use Test;

plan 1;

is foo, ‘foo’, ‘foo returns foo’;
