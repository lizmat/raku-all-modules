use v6;
use Test;

use Test::Base;

plan 1; # because 'ONLY' was specified.

for blocks() {
    is EVAL($_<input>), .expected;
}

=finish

=== simple
--- input: 3+2
--- expected: 5

