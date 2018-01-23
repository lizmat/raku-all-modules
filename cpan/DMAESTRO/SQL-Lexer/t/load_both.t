use v6;
use Test;

use MONKEY-SEE-NO-EVAL;
use-ok('SQL::Lexer');
use-ok('SQL::Basic');
ok(EVAL('use SQL::Lexer; use SQL::Basic; my $a = 1'), 'Basic module can be loaded with SQL::Lexer');

done-testing;
