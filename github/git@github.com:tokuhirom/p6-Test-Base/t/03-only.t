use v6;
use Test;

use Test::Base;

plan 1; # because 'ONLY' was specified.

for blocks($=finish) {
    is EVAL($_<input>), .expected;
}

=finish

=== simple
--- input: 3+2
--- expected: 5

=== more
--- ONLY
--- input: 4+2
--- expected: 6

