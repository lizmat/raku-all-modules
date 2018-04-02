use v6.c;

use Test;

use Lingua::Lipogram;

ok  lipogram('abc', Empty);
ok  lipogram('abc', ('d',));
ok  lipogram('abc', ('d', 'e'));
nok lipogram('abc', ('a',));
nok lipogram('abc', ('a', 'b'));

ok  lipogram('t/abc.txt'.IO, '');
ok  lipogram('t/abc.txt'.IO, 'd');
ok  lipogram('t/abc.txt'.IO, 'de');
nok lipogram('t/abc.txt'.IO, 'a');
nok lipogram('t/abc.txt'.IO, 'ab');

ok  lipogram('t/abc.txt'.IO, 'z' .. 'a');
ok  lipogram('t/abc.txt'.IO, 'd' .. 'd');
ok  lipogram('t/abc.txt'.IO, 'd' .. 'e');
nok lipogram('t/abc.txt'.IO, 'a' .. 'a');
nok lipogram('t/abc.txt'.IO, 'a' .. 'b');

ok  lipogram('abc', '');
ok  lipogram('abc', 'd');
ok  lipogram('abc', 'de');
nok lipogram('abc', 'a');
nok lipogram('abc', 'ab');

ok  lipogram('abc', 'z' .. 'a');
ok  lipogram('abc', 'd' .. 'd');
ok  lipogram('abc', 'd' .. 'e');
nok lipogram('abc', 'a' .. 'a');
nok lipogram('abc', 'a' .. 'b');

done-testing;
