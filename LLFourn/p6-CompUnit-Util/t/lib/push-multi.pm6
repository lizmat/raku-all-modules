use CompUnit::Util :push-multi;

BEGIN { push-unit-multi('EXPORT::DEFAULT::&foo', my multi foo ('one') { "one" } ) };
BEGIN { push-unit-multi('EXPORT::DEFAULT::&foo', my multi foo ('two') { "two" } ) };

BEGIN { push-unit-multi 'EXPORT::DEFAULT::&bar',my proto bar(Numeric) {*} }
BEGIN { push-unit-multi 'EXPORT::DEFAULT::&bar',my multi bar(Int) { 'Int' } }
BEGIN { push-unit-multi 'EXPORT::DEFAULT::&bar',my multi bar(Num) { 'Num' } }
BEGIN { push-unit-multi 'EXPORT::DEFAULT::&non-multi',sub (Int) { 'Int' } }
BEGIN { push-unit-multi 'EXPORT::DEFAULT::&non-multi',sub (Num) { 'Num' } }

class Foo { }

sub EXPORT {
    {
        push-lexical-multi('&baz',my multi baz('one') { "one"});
    }
    {
        push-lexical-multi('&baz',my multi baz('two') { "two"});
    }
    {
        push-lexical-multi('&no-clobber',my multi no-clobber('two') { 'two' });
    }

    {
        push-lexical-multi('&postcircumfix:<{ }>',sub (Foo:D,Str:D) { "win" });
    }
    {};
}
