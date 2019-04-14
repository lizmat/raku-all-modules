#!/usr/bin/env perl6

use v6;

for (3, 1..3, "m" ) -> $m {
    .say with $m.?bounds()
}

=output
(1 3)
