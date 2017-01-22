#!/usr/bin/env perl6
use v6;

use Test;

my $p;

$p = run $*EXECUTABLE, 't/testclass.p6', 'command-one', 4, :out;
is $p.out.slurp-rest, "one\n", 'ran command-one';

$p = run $*EXECUTABLE, 't/testclass.p6', 'command-two', :out;
is $p.out.slurp-rest, "two\n", 'ran command-two';

$p = run $*EXECUTABLE, 't/testclass.p6', 'command-three', 'x', 'y', :out;
is $p.out.slurp-rest, "three\n", 'ran command-three';

done-testing;
