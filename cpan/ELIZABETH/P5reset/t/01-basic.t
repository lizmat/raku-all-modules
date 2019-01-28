use v6.c;
use Test;
use P5reset;

plan 8;

ok defined(::('&reset')),         'is &reset imported?';
nok defined(P5reset::{'&reset'}), 'is &reset externally NOT accessible?';

our $a = 42;
our @b = 1,2,3;
our %c = a => 42, b => 666;

reset("a");
nok $a, 'was $a reset';
ok  @b, 'was @b not reset';
ok  %c, 'was %c not reset';

reset("a-c");
nok $a, 'was $a still reset';
nok @b, 'was @b reset';
nok %c, 'was %c reset';

# vim: ft=perl6 expandtab sw=4
