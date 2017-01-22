use Test;

use lib 'lib';

use Text::Diff::Sift4;

is
	sift4("xaaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", "baaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", 10, 10),
	10;

is
	sift4("xaaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", "baaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", 20, 20),
	20;

is
	sift4("xaaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", "baaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", 20),
	1;

is
	sift4("xaaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", "baaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa"),
	20;

is
	sift4("a", "a"),
	0,
	'the same single letters should have a difference of 0';

is
	sift4("a", "b"),
	1,
	'different single letters should have a difference of 1';

is
	sift4("aa", "aa", 0, 0),
	0;

is
	sift4("aa", "aa", 0, 1),
	1;

is
	sift4("aa", "aa", 0, 2),
	2;

is
	sift4("aa", "aa", 0, 3),
	0;

is
	sift4("aa", "aa", 1, 0),
	0;

is
	sift4("aa", "aa", 1, 1),
	1;

is
	sift4("aa", "aa", 1, 2),
	2;

is
	sift4("aa", "aa", 1, 3),
	0;

is
	sift4("aa", "aa", 2, 0),
	0;

is
	sift4("aa", "aa", 2, 1),
	1;

is
	sift4("aa", "aa", 2, 2),
	2;

is
	sift4("aa", "aa", 2, 3),
	0;

is
	sift4("aa", "aa", 3, 0),
	0;

is
	sift4("aa", "aa", 3, 1),
	1;

is
	sift4("aa", "aa", 3, 2),
	2;

is
	sift4("aa", "aa", 3, 3),
	0;

is
	sift4("aa", "aa", -1, -1),
	1;

is
	sift4("aa", "aa", 1, -1),
	1;

is
	sift4("aa", "aa", -1, 1),
	1;

is
	sift4("aa", "aabb"),
	2;

is
	sift4("aaaa", "aabb"),
	2;

is
	sift4("abba", "aabb"),
	1;

is
	sift4("aaaa", "abbb"),
	3;

is
	sift4("123456789", "987654321"),
	5;

is
	sift4("123 nowhere ave", "123 n0where 4ve"),
	2;

is
	sift4("bisectable6", "disectable6"),
	1,
	'Issue #3';

done-testing;

# vim: ft=perl6
