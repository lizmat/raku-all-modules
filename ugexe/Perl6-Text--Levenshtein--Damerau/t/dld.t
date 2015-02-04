use v6;
use Test;
plan 31;
use Text::Levenshtein::Damerau;


is( dld('four','four'),                     0,  'matching');
is( dld('four','for'),                      1,  'insertion');
is( dld('four','fourth'),                   2,  'deletion');
is( dld('four','fuor'),                     1,  'transposition');
is( dld('four','fxxr'),                     2,  'substitution');
is( dld('four','FOuR'),                     3,  'case');
is( dld('four',''),                         4,  'target empty');
is( dld('','four'),                         4,  'source empty');
is( dld('',''),                             0,  'source & target empty');
is( dld('11','1'),                          1,  'numbers');
is( dld('xxx','x',1),                     Nil,  '> max distance setting');
is( dld('abab','baba',1),                 Nil,  '> max distance setting (bypass length eject)');
is( dld('xxx','xx',1),                      1,  '<= max distance setting');

# some extra maxDistance tests
is( dld("xxx","xxxx",0),                  Nil,  'misc 1');
is( dld("xxx","xxxx",1),                    1,  'misc 1');
is( dld("xxx","xxxx",2),                    1,  'misc 2');
is( dld("xxx","xxxx",3),                    1,  'misc 3');
is( dld("xxxx","xxx",1),                    1,  'misc 4');
is( dld("xxxx","xxx",2),                    1,  'misc 5');
is( dld("xxxx","xxx",3),                    1,  'misc 6');
is( dld("xxxxxx","xxx",2),                Nil,  'misc 7');
is( dld("xxxxxx","xxx",3),                  3,  'misc 8');
is( dld("a","xxxxxxxx",5),                Nil,  'misc 9 (length shortcut)');

# Test some utf8
is( dld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'),                     0,  'matching (utf8)');
is( dld('ⓕⓞⓤⓡ','ⓕⓞⓡ'),                      1,  'insertion (utf8)');
is( dld('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ'),                   2,  'deletion (utf8)');
is( dld('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'),                     1,  'transposition (utf8)');
is( dld('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'),                     2,  'substitution (utf8)');

# test larger strings
is( dld('four' x 20, 'fuor' x 20),         20,  'lengths of 100');
is( dld('four' x 20, 'fuor' x 20, 19),    Nil,  'lengths of 100 exceeding max value');
is( dld('four' x 20, 'fuor' x 20, 21),     20,  'lengths of 100 under max value');
