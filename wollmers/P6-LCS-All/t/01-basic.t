use v6;
use Test;
use LCS::All;

plan *;

is-deeply([allLCS([<A B C>], [<D E F>])], $[[[],],], 'the lcs of two sequences with nothing in common should be empty');


done-testing;
