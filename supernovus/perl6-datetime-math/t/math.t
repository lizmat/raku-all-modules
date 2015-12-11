use v6;

use lib 'lib';

use Test;
use DateTime::Math;

plan 17;

my $d = DateTime.new(:year(2010), :month(12), :day(31));

my $t1 = $d + to-seconds(1, 'd');

is $t1.year, 2011, 'year changed correctly, add 1d';
is $t1.month, 1, 'month changed correctly, add 1d';
is $t1.day, 1, 'day changed correctly, add 1d';

my $t2 = $d - to-seconds(1, 'y');

is $t2.year, 2009, 'year changed correctly, subtract 1y';
is $t2.month, 12, 'month changed correctly, subtract 1y';
is $t2.day, 31, 'day changed correctly, subtract 1y';

is $t1 - $t2, 31622400, 'DateTime - DateTime';
is from-seconds($t1 - $t2, 'd'), 366, 'from-seconds to days';

ok $t1 > $t2, 'DateTime > DateTime';
ok $t2 < $t1, 'DateTime < DateTime';
ok $t1 >= $t2, 'DateTime >= DateTime';
ok $t2 <= $t1, 'DateTime <= DateTime';
ok !($t1 == $t2), 'DateTime == DateTime';
is $t1 cmp $t2, 'More', 'DateTime cmp DateTime';
is $t1 <=> $t2, 'More', 'DateTime <=> DateTime';
ok $t1 != $t2, 'DateTime != DateTime';

is duration-from-to(30, 'm', 'h'), 0.5, 'duration-to-from() works.';

