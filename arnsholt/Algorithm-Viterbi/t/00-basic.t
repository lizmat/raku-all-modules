use v6;

use Test;

use Algorithm::Viterbi;

plan 7;

my Algorithm::Viterbi $hmm .= new(:alphabet<H C>);
pass("creating new decoder");

$hmm.train("t/eisner.tt");
ok($hmm.p-transition<C><H> == 13/68, "C -> H == 13/68?");
ok($hmm.p-emission<C><3> == 5/34, "C -> 3 == 5/34?");

my $result = $hmm.decode(<1 1 3 3 3 3 1 1 1 1>.list);
is_deeply($result, ["H", "H", "H", "H", "H", "H", "C", "C", "C", "C"],
    "correctly decodes <1 1 3 3 3 3 1 1 1 1>");

my Algorithm::Viterbi $other .= new(:alphabet<H C>,
    :p-transition($hmm.p-transition), :p-emission($hmm.p-emission));
pass("creating decoder with explicit probabilities");

$result = $other.decode(<1 1 3 3 3 3 1 1 1 1>.list);
is_deeply($result, ["H", "H", "H", "H", "H", "H", "C", "C", "C", "C"],
    "correctly decodes <1 1 3 3 3 3 1 1 1 1>");

dies_ok(-> { my Algorithm::Viterbi $hmm .= new; },
    "impossible to create alphabet-less decoder");
