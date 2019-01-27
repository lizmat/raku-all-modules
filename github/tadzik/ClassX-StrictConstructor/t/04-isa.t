use v6.c;
use Test;
use ClassX::StrictConstructor;

role A {
    has $.a;
}
class B does A does ClassX::StrictConstructor {

}


lives-ok {
    my $b = B.new(a => 1);
    diag $b.perl;
    ok $b.isa(B), 'B.new.isa(B)';

}, 'Can create an instace of a Class that does StrictClass';

dies-ok {
    B.new(:what(1));
}, 'Can not create an instance of a class that does StrictClass with to many parameters';

done-testing;
