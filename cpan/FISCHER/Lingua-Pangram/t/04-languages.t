use v6.c;

use Test;

use Lingua::Pangram;

nok pangram-de('abc');
nok pangram-de('abcdefghijklmnopqrstuvwxyzÄÖÜ');
ok  pangram-de('abcdefghijklmnopqrstuvwxyzÄÖÜß');

nok pangram-en('abc');
ok  pangram-en('abcdefghijklmnopqrstuvwxyz');
ok  pangram-en('abcdefghijklmnopqrstuvwxyzÄÖÜß');

nok pangram-es('abc');
ok  pangram-es('abcdefghijklmnopqrstuvwxyzñ');
ok  pangram-es('abcdefghijklmnopqrstuvwxyzñ', False);
nok pangram-es('abcdefghijklmnopqrstuvwxyzñ', True);
ok  pangram-es('abcdefghijklmnopqrstuvwxyzñchllrr');
ok  pangram-es('abcdefghijklmnopqrstuvwxyzñchllrr', True);
ok  pangram-es('abcdefghijklmnopqrstuvwxyzñchllrr', False);

nok pangram-fr('abc');
ok  pangram-fr('abcdefghijklmnopqrstuvwxyz');
ok  pangram-fr('abcdefghijklmnopqrstuvwxyz', False);
nok pangram-fr('abcdefghijklmnopqrstuvwxyz', True);
ok  pangram-fr('abcdefghijklmnopqrstuvwxyzæœ');
ok  pangram-fr('abcdefghijklmnopqrstuvwxyzæœ', False);
ok  pangram-fr('abcdefghijklmnopqrstuvwxyzæœ', True);

nok pangram-ru('abc');
nok pangram-ru('абв');
ok  pangram-ru('абвгдеёжзийклмнопрстуфхцчшщъыьэюя');

done-testing;
