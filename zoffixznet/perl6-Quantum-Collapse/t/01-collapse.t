use lib 'lib';
use Test;
use Quantum::Collapse;

is-deeply n<- <1 .5 1e0 1+1i a>, @(1, .5, 1e0, 1+1i, 'a'),
    'unicode numeric collapse';

is-deeply s<- <1 .5 1e0 1+1i a>, @('1', '.5', '1e0', '1+1i', 'a'),
    'unicode stringy collapse';

done-testing;
