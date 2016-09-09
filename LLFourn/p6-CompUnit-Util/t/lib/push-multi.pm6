use CompUnit::Util :push-multi;

BEGIN { push-unit-multi('EXPORT::DEFAULT::&foo', my multi foo ('one') { "one" } ) }
BEGIN { push-unit-multi('EXPORT::DEFAULT::&foo', my multi foo ('two') { "two" } ) }

BEGIN { push-unit-multi 'EXPORT::DEFAULT::&bar',my proto bar(Numeric) {*} }
BEGIN { push-unit-multi 'EXPORT::DEFAULT::&bar',my multi bar(Int) { 'barInt' } }
BEGIN { push-unit-multi 'EXPORT::DEFAULT::&bar',my multi bar(Num) { 'barNum' } }

# BEGIN  push-unit-multi 'EXPORT::DEFAULT::&non-multi',sub (Int) { 'nmInt' };
# BEGIN  push-unit-multi 'EXPORT::DEFAULT::&non-multi',sub (Num) { 'nmNum' };
# BEGIN  push-unit-multi 'EXPORT::DEFAULT::&non-multi2',sub (Str) { 'nm2Str' }

class Foo { }

sub EXPORT {
    {
        push-lexical-multi('&baz',my multi baz('one') { "bazone"});
    }
    {
        push-lexical-multi('&baz',my multi baz('two') { "baztwo"});
    }
    {
        push-lexical-multi('&no-clobber',my multi no-clobber('two') { 'two' });
    }

    {
        push-lexical-multi('&postcircumfix:<{ }>',sub (Foo:D,Str:D) { "win" });
    }
    {};
}
