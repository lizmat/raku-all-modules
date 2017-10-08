#!/usr/bin/perl6

use v6;

# a test just for a loop

use Test;
use Coro::Simple;

plan 4;

my &xtimes = coro -> &block, $init, $final, $step {
    for $init, $init + $step ... $final -> $i {
        block($i);
    }
}

my $loop = (xtimes -> $x {
    say "Hello, World! -> { $x }";
    suspend;
}, 1, 3, 1);

ok $loop( );
ok $loop( );
ok $loop( );
nok $loop( ); # dead

# end of test