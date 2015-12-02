use v6;
use Test;
use JavaScript::SpiderMonkey;


my $var = js-eval('(function (a, b) { return b ? a + b : a ? a : "var"; })');

is $var.js-val.type, 'function', 'value is a function';
is-deeply $var(),      'var', 'no arg returns a string';
is-deeply $var('arg'), 'arg', 'string arg returns it';
is-deeply $var(True),  True,  'boolean arg returns it';
is-deeply $var(1, 2 ),  3e0,  'two numbers are added';

is-deeply $var('hello,', ' world!'), 'hello, world!',
          'two strings are concatenated';


my $obj = js-eval(q:to/JS/);
    ({
        thing : "nothing",
        get   : function() { return this.thing; },
        set   : function(t) { this.thing = t; return this; },
    })
    JS

given $obj
{
    is .js-val.type,       'object',   'value is an object';
    is .<get>.js-val.type, 'function', 'get is a function';
    is .<set>.js-val.type, 'function', 'set is a function';
    is-deeply .<thing>,    'nothing',  'attribute has the right value';

    is .call-func('set', 123).js-val.type, 'object', 'calling set returns object';
    is-deeply .<thing>.Num, 123e0, 'attribute has the right value';

    is-deeply .call-func('get'), 123e0, 'getting attribute returns right value';

    dies-ok { .call-func('nonexistent') }, 'calling nonexistent method fails';
    dies-ok { .call-func('thing')       }, 'calling non-function fails';

    is .set($_).js-val.type, 'object', 'set with FALLBACK';
    is-deeply .get.js-val, $_.js-val, 'get with FALLBACK';

    # This returns X::AdHoc instead of X::TypeCheck::Binding, see perl #126763
    throws-like { .no-kebap }, X::AdHoc, 'calling kebap-case fails';
}

done-testing
