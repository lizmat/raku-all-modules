#!/usr/bin/env perl6

use Test;
use Test::Class;

class Foo does Test::Class { }

isa-ok(Foo.new, Foo);
does-ok(Foo.new, Test::Class);

done-testing;
