#!/usr/bin/perl6

use v6;

# a test just for a loop

use Test;
use Coro::Simple;

plan 4;

# loop example
my &xtimes = coro -> &block, $init, $final, $step {
    for $init, $init + $step ... $final -> $i {
        block($i);
    }
}

# generator function
my $loop = (xtimes -> $x {
    say "Hello, World! -> { $x }";
    suspend; # default yield: True
}, 1, 3, 1);

ok $loop( );

sleep 0.5;
ok $loop( );

sleep 0.5;
ok $loop( );

sleep 0.5;
nok $loop( ); # here, the coroutine is dead

# end of test