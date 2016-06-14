use Test;

use lib 'lib';

use Text::Diff::Sift4;

my Int $a;

$a = sift4("xaaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", "baaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", 10, 10);
ok ($a == 10, '');

$a = sift4("xaaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", "baaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", 20, 20);
ok ($a == 20, '');

$a = sift4("xaaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", "baaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", 20);
ok ($a == 20, '');

$a = sift4("xaaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa", "baaaaaaaaaaaaaaaaaaaxaaaaaaaaaaaaaaaaaaa");
ok ($a == 20, '');

$a = sift4("a", "a");
ok ($a == 0, 'the same single letters should have a difference of 0');

$a = sift4("a", "b");
ok ($a == 1, 'different single letters should have a difference of 1');

$a = sift4("aa", "aa", 0, 0);
ok ($a == 0, '');

$a = sift4("aa", "aa", 0, 1);
ok ($a == 1, '');

$a = sift4("aa", "aa", 0, 2);
ok ($a == 2, '');

$a = sift4("aa", "aa", 0, 3);
ok ($a == 0, '');

$a = sift4("aa", "aa", 1, 0);
ok ($a == 0, '');

$a = sift4("aa", "aa", 1, 1);
ok ($a == 1, '');

$a = sift4("aa", "aa", 1, 2);
ok ($a == 2, '');

$a = sift4("aa", "aa", 1, 3);
ok ($a == 0, '');

$a = sift4("aa", "aa", 2, 0);
ok ($a == 0, '');

$a = sift4("aa", "aa", 2, 1);
ok ($a == 1, '');

$a = sift4("aa", "aa", 2, 2);
ok ($a == 2, '');

$a = sift4("aa", "aa", 2, 3);
ok ($a == 0, '');

$a = sift4("aa", "aa", 3, 0);
ok ($a == 0, '');

$a = sift4("aa", "aa", 3, 1);
ok ($a == 1, '');

$a = sift4("aa", "aa", 3, 2);
ok ($a == 2, '');

$a = sift4("aa", "aa", 3, 3);
ok ($a == 0, '');

$a = sift4("aa", "aa", -1, -1);
ok ($a == 1, '');

$a = sift4("aa", "aa", 1, -1);
ok ($a == 1, '');

$a = sift4("aa", "aa", -1, 1);
ok ($a == 1, '');

$a = sift4("aa", "aabb");
ok ($a == 2, '');

$a = sift4("aaaa", "aabb");
ok ($a == 2, '');

$a = sift4("abba", "aabb");
ok ($a == 1, '');

$a = sift4("aaaa", "abbb");
ok ($a == 3, '');

$a = sift4("123456789", "987654321");
ok ($a == 5, '');

$a = sift4("123 nowhere ave", "123 n0where 4ve");
ok ($a == 2, '');

done-testing;
