use lib <lib>;
use WhereList;

subset StrArray of Array where all-items *.chars ≥ 3, Str, *.contains: any <o a e>;

say [<foo bar meow>] ~~ StrArray; # OUTPUT: «True␤»
say ['dddrrrrrrrrr'] ~~ StrArray; # OUTPUT: «False␤»
say [<ha ha ha ha >] ~~ StrArray; # OUTPUT: «False␤»
say [<ooh come onn>] ~~ StrArray; # OUTPUT: «True␤»


class Foo {
    has @.bar where all-items any Str|Nil|Int:D, * === Any;
}

sub foo (+bar where all-items any Str|Nil|Int:D, * === Any) {
    dd bar;
}

foo 42, Str, Nil, Any;
