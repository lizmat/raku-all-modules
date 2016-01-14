use Test;
use lib $?FILE.IO.parent.child("lib").Str;
use MONKEY-SEE-NO-EVAL;
plan 2;

{
    EVAL q|
    use set-export;
    use CompUnit::Util :get-symbols;
    BEGIN is get-globalish('Foo::Bar::Baz'),'foobarbaz','get-globalish';
    BEGIN is get-globalish, GLOBAL,'get-globalish without args';
    |;
}
