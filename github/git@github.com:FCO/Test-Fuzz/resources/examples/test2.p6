use lib <lib ../../lib>;
use Test::Fuzz;

subset Even where * %% 2;
sub returns-an-even-only(Int:D $x --> Even ) is fuzzed { $x² }

run-tests
