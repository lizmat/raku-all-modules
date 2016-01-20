use CompUnit::Util :set-symbols;

BEGIN set-unit('EXPORT::DEFAULT::&foo',sub foo { });
BEGIN set-unit('GLOBALish::Foo::Bar::Baz','foobarbaz');

sub EXPORT {
    set-unit('UNIT-EXPORT-sub-Foo','foo');
    set-unit('Unit::Foo','unitfoo');
    set-lexpad('lex-EXPORT-sub-Foo','foo');
    set-lexpad('Lexi::Foo','lexifoo');
    {};
}
