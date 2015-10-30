use v6;
use Test;

use Test::Base;

for blocks($=finish) {
    is EVAL($_<input>), .expected;
}

done-testing;

=finish

=== simple
--- input: 3+2
--- expected: 5

=== more
--- input: 4+2
--- expected: 6

