use Test;
use lib $?FILE.IO.parent.child("lib").Str;
use MONKEY-SEE-NO-EVAL;
plan 5;

{
    EVAL q|
    use set-symbols;
    use CompUnit::Util :get-symbols;
    BEGIN is get-unit('Foo::Bar::Baz'),'foobarbaz','get-unit';
    BEGIN is get-lexpad('Lexi::Foo'),'lexifoo','get-lexpad';
    BEGIN is get-unit('UNIT-EXPORT-sub-Foo'),'foo','no "::"';
    {
        BEGIN is get-lexical('lex-EXPORT-sub-Foo'),'foo','get-lexical';
        # :: doesn't work atm
        #BEGIN is get-lexical('Lexi::Foo'),'foo','get-lexical';
        BEGIN is get-lexpad('Lexi::Foo'),Nil,'get-lexpad non-existent';
    }
    |;
}
