use lib <lib>;
use Testo;
use WhereList;
plan 8;

subset StrArray of Array
  where all-items Str, *.chars ≥ 3, *.contains: any <o a e>;

is [<foo bar meow>], StrArray;
is [<ooh come onn>], StrArray;
is ['dddrrrrrrrrr'] ~~ StrArray, *.not;
is [<ha ha ha ha >] ~~ StrArray, *.not;

sub foo (+bar where all-items any Str|Nil|Int:D, * === Any) { 42 }

is foo(42, Str, Nil, Any), 42;

try foo Int, Str, Nil, Any;
is $!, X::TypeCheck;


class Foo {
    has @.bar where all-items any(Str|Nil|Int:D, * === Any), * !~~ IntStr
}
try Foo.new(:bar<42 meows>).bar;
is $!, X::TypeCheck;

subset Meows where all-items {die 'meow'};
is [42] ~~ Meows, *.not;
