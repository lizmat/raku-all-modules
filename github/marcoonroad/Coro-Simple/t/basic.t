#!/usr/bin/perl6

use v6;

use Test;
use Coro::Simple;

plan 5;

my $coro = coro {
    my $cnt = 1;
    say "cnt has: $cnt";
    yield $cnt;

    $cnt += 1;
    say "cnt (again) has: $cnt";
    yield [ $cnt, $cnt ];

    $cnt = "Now I'm a string!";
    say "Now, cnt is a string? { $cnt ~~ Str }";
    yield $cnt;

    say "Hi, folks!";
    say "Hello ", "World!" ;
    suspend;

    say "See ya later";
    yield [ "Bye-bye!".comb ];
};

my $gen    = $coro( );
my $result = $gen( );

while ($result !~~ Bool) || (?$result) {
    ok defined $result;
    $result = $gen( );
}

# end of test