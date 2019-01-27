use v6.c;
use Test;
use ClassX::StrictConstructor;

class Foo does ClassX::StrictConstructor {
    has $.a;
    has %.b;
}

lives-ok {
    Foo.new(a => 1, b => {bb => 2, bbb => 3});
}, 'Can create an instace of a Class that does StrictClass';

dies-ok {
    Foo.new(a => 1, b => 2, c => 3);
}, 'Can not create an instance of a class that does StrictClass with to many parameters';

done-testing;
