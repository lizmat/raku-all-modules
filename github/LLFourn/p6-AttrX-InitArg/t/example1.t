use Test;
use AttrX::InitArg;

plan 1;

class Foo {
    has $!attr is init-arg;
    method works { $!attr }
}

is Foo.new( attr => 'win' ).works ,'win';
