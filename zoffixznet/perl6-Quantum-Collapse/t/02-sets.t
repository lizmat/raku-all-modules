use lib 'lib';
use Test;
use Quantum::Collapse;

subtest {
    cmp-ok 2,    &[∈], n<- <2 a>,    'Int inside a set with IntStr';
    cmp-ok 2e2,  &[∈], n<- <2e2 a>,  'Num inside a set with NumStr';
    cmp-ok .5,   &[∈], n<- <.5 a>,   'Rat inside a set with RatStr';
    cmp-ok 2+2i, &[∈], n<- <2+2i a>, 'Complex inside a set with ComplexStr';
}, 'collapse to numeric';

subtest {
    cmp-ok '2',    &[∈], s<- <2 a>,    'Int inside a set with IntStr';
    cmp-ok '2e2',  &[∈], s<- <2e2 a>,  'Num inside a set with NumStr';
    cmp-ok '.5',   &[∈], s<- <.5 a>,   'Rat inside a set with RatStr';
    cmp-ok '2+2i', &[∈], s<- <2+2i a>, 'Complex inside a set with ComplexStr';
}, 'collapse to string';

done-testing;
