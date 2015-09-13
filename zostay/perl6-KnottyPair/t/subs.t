#!perl6

use v6;

use Test;
use KnottyPair;

sub call(*@pairs) {
    isa-ok @pairs[0], KnottyPair;
    is @pairs[0].key, 'a';
    is @pairs[0].value, 1;

    isa-ok @pairs[1], KnottyPair;
    is @pairs[1].key, 'b';
    is @pairs[1].value, 2;

    isa-ok @pairs[2], KnottyPair;
    is @pairs[2].key, 'c';
    is @pairs[2].value, 3;
}

call('a' =x> 1, 'b' =x> 2, 'c' =x> 3);

done-testing;
