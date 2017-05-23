use lib 'lib'; # -*- mode: perl6 -*-

use Test;

plan(1);

try require Math::Sequences;
is $!.WHAT, X::AdHoc, "Throws error";


done-testing;
# vim: sw=4 softtabstop=4 expandtab ai ft=perl6
