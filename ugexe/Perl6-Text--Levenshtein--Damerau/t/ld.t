use v6;
use Test;
plan 42;
use Text::Levenshtein::Damerau;


is( ld('four','for'),                       1,  'insertion');
is( ld('four','four'),                      0,  'matching');
is( ld('four','fourth'),                    2,  'deletion');
is( ld('four','fuor'),                      2,  '(no) transposition');
is( ld('four','fxxr'),                      2,  'substitution');
is( ld('four','FOuR'),                      3,  'case');
is( ld('four',''),                          4,  'target empty');
is( ld('','four'),                          4,  'source empty');
is( ld('',''),                              0,  'source and target empty');
is( ld('111','11'),                         1,  'numbers');

is( ld("foo","four"),                       2,  "foo four");
is( ld("foo","foo"),                        0,  "foo foo");
is( ld("cow","cat"),                        2,  "cow cat");
is( ld("cat","moocow"),                     5,  "cat moocow");
is( ld("cat","cowmoo"),                     5,  "cat cowmoo");
is( ld("sebastian","sebastien"),            1,  "sebastian sebastien");
is( ld("more","cowbell"),                   5,  "more cowbell");

# test max distance
is( ld("foo","four",1),                   Int,  "(max distance) foo four (explicit return value)");
is( ld("foo","foo",1),                      0,  "(max distance) foo foo");
is( ld("cow","cat",2),                      2,  "(max distance) cow cat");
is( ld("cat","moocow",5),                   5,  "(max distance) cat moocow");
nok( ld("cat","cowmoo",4),                      "(max distance) cat cowmoo");
is( ld("sebastian","sebastien",4),          1,  "(max distance) sebastian sebastien");
is( ld("more","cowbell",0),                 5,  "(max distance) 0 = no max distance");
nok( ld("a","xxxxxxxx",5),                      "(max distance) length difference shortcut");

# some extra maxDistance tests
is( ld("xxx","xxxx",1),                     1,  'misc 1');
is( ld("xxx","xxxx",2),                     1,  'misc 2');
is( ld("xxx","xxxx",3),                     1,  'misc 3');
is( ld("xxxx","xxx",1),                     1,  'misc 4');
is( ld("xxxx","xxx",2),                     1,  'misc 5');
is( ld("xxxx","xxx",3),                     1,  'misc 6');
nok( ld("xxxxxx","xxx",2),                      'misc 7');
is( ld("xxxxxx","xxx",3),                   3,  'misc 8');
nok( ld("a","xxxxxxxx",5),                      'misc 9 (length shortcut)');

# Test some utf8
is( ld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'),                      0,  'matching (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓞⓡ'),                       1,  'insertion (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ'),                    2,  'deletion (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'),                      2,  '(no) transposition (utf8)');
is( ld('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'),                      2,  'substitution (utf8)');

# test larger strings
is( ld('four' x 20, 'fuor' x 20),          40,  'lengths of 100');
nok( ld('four' x 20, 'fuor' x 20, 39),          'lengths of 100 exceeding max value');
is( ld('four' x 20, 'fuor' x 20, 41),      40,  'lengths of 100 under max value');
