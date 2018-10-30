#!/usr/bin/env perl6

use Foo::Dependencies::A-on-B;
use Test;

plan 1;

is foo, ‘foo’, ‘foo returns foo’;
