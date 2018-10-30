#!/usr/bin/env perl6

use lib 'lib';
use Module::Does;
use Test;

plan 5;

class C { has $.x = 5; }
role D { has $.y = 42; }
class F does D { };

class A does Module::Does[@(C, D => 'E', Module::Does)] {
  has $.xx = 24; 
  method base-types { %!base-types; }
}

my A $a .=new;

ok C ~~ any(@($a.base-types<C>));
ok F ~~ any(@($a.base-types<D>));
ok D ~~ any(@($a.base-types<D>));
ok Module::Does ~~ any(@($a.base-types<Module::Does>));
ok A ~~ any(@($a.base-types<Module::Does>));

# vi:syntax=perl6
