use v6.c;
use Test;
use Acme::Don't;

plan 2;

my $seen = False;
don't { $seen = True }

nok $seen, 'did we not execute?';

$seen = False;
my $times = 10;
don't { $seen = True } while --$times;
nok $seen, 'did we not execute?';

# vim: ft=perl6 expandtab sw=4
