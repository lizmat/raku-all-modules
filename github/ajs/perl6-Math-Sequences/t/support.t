use v6.c;

use Test;

use Math::Sequences::Integer :support;

sub postfix:<!>($n) { [*] 1..$n }

plan 15;

is 10 choose 3, 10! / (3! * (10-3)!), "choose";
is 10 ichoose 3, 10! div (3! * (10-3)!), "choose";
# euler-up-down($i)
# binpart($n)
is factors(2), (2), "factors(10)";
is factors(4), (2,2), "factors(4)";
is factors(10), (2,5), "factors(10)";
is factors(12), (2,2,3), "factors(12)";
is factors(13), (13), "factors(13)";
is divisors(2), (1,2), "divisors(2)";
is divisors(4), (1,2,4), "divisors(4)";
is divisors(10), (1,2,5,10), "divisors(10)";
is divisors(13), (1,13), "divisors(13)";
is sigma(1), 1, "sigma(1)";
is sigma(2), 3, "sigma(2)";
is sigma(3), 4, "sigma(3)";
is sigma(4), 7, "sigma(4)";
