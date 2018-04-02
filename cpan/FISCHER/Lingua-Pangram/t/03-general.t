use v6.c;

use Test;

use Lingua::Pangram;

ok  pangram('abc', <a b>);
nok pangram('abc', <a b c d>);
ok  pangram('abc', <ab bc abc>);
nok pangram('abc', <ab bc abc ba>);

ok  pangram('abc', 'ab');
nok pangram('abc', 'abcd');

ok  pangram('abc', 'a' .. 'b');
nok pangram('abc', 'a' .. 'd');

ok  pangram('abc', 'ab', <ab bc abc>);
nok pangram('abc', 'ab', <ab bc abc ba>);

ok  pangram('abc', 'a' .. 'b', <ab bc abc>);
nok pangram('abc', 'a' .. 'b', <ab bc abc ba>);

done-testing;
