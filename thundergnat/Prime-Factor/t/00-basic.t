use v6;
use Test;
use Prime::Factor;

for '', 'a', .5, pi, 0, -12 -> $p {
    dies-ok { factors($p) }, "Dies ok with bad parameter $p";
}

is factors(1), (1), 'factors 1 ok';
is factors(2), (2), 'factors 2 ok';
is factors(7), (7), 'factors 7 ok';
is factors(12), (2,2,3), 'factors 12 ok';
is factors(2016), (2,2,2,2,2,3,3,7), 'factors 2016 ok';
is factors(123899765), (5,11,11,204793), 'factors 123899765 ok';

done-testing;
