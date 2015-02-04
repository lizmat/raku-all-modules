#!/usr/bin/perl6

use v6;

# most simple test

use Test;
use Coro::Simple;

plan 5;

# coroutine example
my $coro = coro { # zero arity block
    my $cnt = 1;
    say "cnt has: $cnt";
    yield $cnt;

    $cnt += 1; # mutable variable
    say "cnt (again) has: $cnt";
    yield [ $cnt, $cnt ];

    $cnt = "Now I'm a string!";
    say "Now, cnt is a string? { $cnt ~~ Str }";
    yield $cnt;

    say "Hi, folks!";
    say "Hello ", "World!" ;
    suspend; # True implicit

    say "See ya later";
    yield [ "Bye-bye!".comb ];
};

# generator function
my $gen = $coro( );

my $result = $gen( );

# loop until $result becomes False
while ($result !~~ Bool) || (?$result) {
    ok defined $result;
    say $result;
    $result = $gen( );
    sleep 0.5;
}

# end of test