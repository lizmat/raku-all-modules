use v6;
use Test;
use Prime::Factor;

for '', 'a', .5, pi, 0, -12 -> $p {
    dies-ok { prime-factors($p) }, "Dies ok with bad parameter $p";
}

is prime-factors(1), (), 'factors of 1 returns nothing ok';
is prime-factors(2), (2), 'factors 2 ok';
is prime-factors(7), (7), 'factors 7 ok';
is prime-factors(12), (2,2,3), 'factors 12 ok';
is prime-factors(25), (5,5), 'factors 25 ok';
is prime-factors(2016), (2,2,2,2,2,3,3,7), 'factors 2016 ok';
is prime-factors(123899765), (5,11,11,204793), 'factors 123899765 ok';
is prime-factors(2²⁹-1), (233,1103,2089), 'factors 536870911 (2²⁹-1) ok';
is prime-factors(2⁴¹-1), (13367,164511353), 'factors 2199023255551 (2⁴¹-1) ok';
is prime-factors(2⁵⁹-1), (179951,3203431780337), 'factors 576460752303423487 (2⁵⁹-1) ok';
is prime-factors(2⁷¹-1), (228479,48544121,212885833), 'factors 2361183241434822606847 (2⁷¹-1) ok';
is prime-factors(2⁷⁹-1), (2687,202029703,1113491139767), 'factors 604462909807314587353087 (2⁷⁹-1) ok';
is prime-factors(2⁹⁷-1), (11447,13842607235828485645766393), 'factors 158456325028528675187087900671 (2⁹⁷-1) ok';
is prime-factors(2¹¹⁷-1), (7,73,79,937,6553,8191,86113,121369,7830118297), 'factors 166153499473114484112975882535043071 (2¹¹⁷-1) ok';
is prime-factors(2²⁴¹-1), (22000409,160619474372352289412737508720216839225805656328990879953332340439), 'factors 3533694129556768659166595001485837031654967793751237916243212402585239551 (2²⁴¹-1) ok';
done-testing;
