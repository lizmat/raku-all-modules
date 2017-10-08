#!perl6

use v6;
use lib 'lib';
use Test;

my $def = q:to/EOCLASS/;
use Object::Permission;
class Foo {
   has $.bar is authorised-by("bar");
   method baz() is authorised-by("baz") {

   }
}
EOCLASS

my $c;

lives-ok { $c = EVAL $def }, "definition with traits compiles";
isa-ok $c, ::('Foo'), "just check it's a class";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
