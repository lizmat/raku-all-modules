use v6;

use Test;

plan 2;

use-ok 'Perl6::Tracer';

my $t = Perl6::Tracer.new();

ok $t, "got an obj";


# vim: expandtab shiftwidth=4 ft=perl6
