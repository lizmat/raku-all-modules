use v6;

use Test;

plan 2;

use-ok 'Rakudo::Perl6::Tracer';

use Rakudo::Perl6::Tracer;

my $t = Rakudo::Perl6::Tracer.new();

ok $t, "got an obj";


# vim: expandtab shiftwidth=4 ft=perl6
