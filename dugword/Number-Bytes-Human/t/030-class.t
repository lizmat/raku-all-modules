#!/usr/bin/env perl6

use v6;
use lib 'lib';

use Number::Bytes::Human;
use Test;

plan 23;

my $human = Number::Bytes::Human;
isa-ok $human, Number::Bytes::Human, '$human is Human';

is $human.format(1023), '1023B', '1023 should read "1023B"';
is $human.format(1024), '1K', '1024 should read "1K"';
is $human.format(1024 ** 2), '1M', '1024 ** 2 should read "1M"';
is $human.format(1024 ** 3), '1G', '1024 ** 3 should read "1G"';
is $human.format(1024 ** 4), '1T', '1024 ** 4 should read "1T"';
is $human.format(1024 ** 5), '1P', '1024 ** 5 should read "1P"';
is $human.format(1024 ** 6), '1E', '1024 ** 6 should read "1E"';
is $human.format(1024 ** 7), '1Z', '1024 ** 6 should read "1Z"';
is $human.format(1024 ** 8), '1Y', '1024 ** 7 should read "1Y"';
is $human.format(-1024 ** 3), '-1G', '1024 ** 3 should read "1G"';
is $human.format(1088602536865), '1014G', '109951162777 should read "1014G"';

is $human.parse('1023B'), 1023, '1023B should yeild 1023';
is $human.parse('1K'), 1024, '1K should yeild 1024';
is $human.parse('1M'), 1024 ** 2, '1M should yield 1048576';
is $human.parse('1G'), 1024 ** 3, '1G should yield 1073741824';
is $human.parse('1T'), 1024 ** 4, '1T should yield 1099511627776';
is $human.parse('1P'), 1024 ** 5, '1P should yield 1125899906842624';
is $human.parse('1E'), 1024 ** 6, '1E should yield 1152921504606846976';
is $human.parse('1Z'), 1024 ** 7, '1Z should yield 1180591620717411303424';
is $human.parse('1Y'), 1024 ** 8, '1Y should yield 1208925819614629174706176';
is $human.parse('-1G'), -1024 ** 3, '-1G should yield -1073741824';
is $human.parse('1014G'), 1088774209536, '1014G should yield 1088774209536';

done-testing;
