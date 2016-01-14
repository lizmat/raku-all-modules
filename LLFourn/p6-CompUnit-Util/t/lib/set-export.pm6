use CompUnit::Util :set-symbols;

BEGIN set-export(%('&foo' => sub foo { }));
BEGIN set-export({EXPORT-Foo => 'foo'});
BEGIN set-globalish({GLOBALish-Foo => 'foo'});
BEGIN set-globalish(%('Foo::Bar::Baz' => 'foobarbaz'));

sub EXPORT {
    set-unit({UNIT-EXPORT-sub-Foo => 'foo'});
    set-unit({'Unit::Foo' => 'unitfoo'});
    set-lexical({lex-EXPORT-sub-Foo => 'foo'});
    set-lexical({'Lexi::Foo' => 'lexifoo'});
    {};

}
