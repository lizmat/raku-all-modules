use v6;

use Test;
use lib 'lib';
use Rakudo::Perl6::Tracer;

plan 1;
my $tracer = Rakudo::Perl6::Tracer.new();
my $code = "#! /usr/bin/env perl6 \n use v6; \n  use Rakudo::Perl6::Tracer; ";
my $result = $tracer.trace({},$code); #  trace the content
ok (not $result ~~ /^note/), "Did not note shebang";


# vim: ft=perl6
