use Test;
use lib $?FILE.IO.parent.child("lib").Str;
use CompUnit::Util :set-symbols;

plan 7;

{
    use set-symbols;
    ok &foo, 'set-export code wtih name';
    is Foo::Bar::Baz,'foobarbaz','set-globlish ::';
    is lex-EXPORT-sub-Foo,'foo','set-lexical';
    is Lexi::Foo, 'lexifoo','set-lexical ::';
}

is UNIT-EXPORT-sub-Foo,'foo','set-unit';
is Unit::Foo,'unitfoo','set-unit ::';
nok ::('lex-EXPORT-sub-Foo'),<set-lexical doesn't leak>;
