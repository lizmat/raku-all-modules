use lib ".";
use Test::Fuzz;

subset Even where * %% 2;
sub returns-an-even-only(Int:D $x) returns Even is fuzzed { $x² }

run-tests
