#!/usr/bin/env perl6

use Foo::Dependencies::Self;
use Test;

plan 1;

is foo, ‘foo’, ‘foo returns foo’;
