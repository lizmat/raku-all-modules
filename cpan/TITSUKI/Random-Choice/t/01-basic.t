use v6.c;
use Test;
use Random::Choice;

lives-ok { choice(:p([0.5,0.2,0.3])) };
lives-ok { choice(:size(5), :p([0.5,0.2,0.3])) };

is choice(:p([1.0])), 0, "Test unbiased dice";
is choice(:size(5), :p([1.0])), 0 xx 5, "Test unbiased dice with size";

subtest {
    my Int $size = 100000;
    my @r = choice(:$size, :p([0.7,0.1,0.1,0.1]));
    is-approx +@r.grep(* == 0) / $size, 0.7, 1e-2;
    is-approx +@r.grep(* == 1) / $size, 0.1, 1e-2;
    is-approx +@r.grep(* == 2) / $size, 0.1, 1e-2;
    is-approx +@r.grep(* == 3) / $size, 0.1, 1e-2;
}, "Test biased dice";

subtest {
    my Int $size = 100000;
    my @r = choice(:$size, :p([0.7,0.2,0,0.1]));
    is-approx +@r.grep(* == 0) / $size, 0.7, 1e-2;
    is-approx +@r.grep(* == 1) / $size, 0.2, 1e-2;
    is-approx +@r.grep(* == 2) / $size, 0, 1e-2;
    is-approx +@r.grep(* == 3) / $size, 0.1, 1e-2;
}, "Test biased dice (contains zero)";

done-testing;
