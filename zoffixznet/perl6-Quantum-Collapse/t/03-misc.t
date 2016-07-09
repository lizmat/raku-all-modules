use lib 'lib';
use Test;
use Quantum::Collapse;

subtest {
    is-deeply n<-<a 2>, @('a', 2), 'list form';

    my @a = <a 2>;
    my @b = 'a', 2;
    is-deeply n<- @a, @b, 'array form';
}, 'return type is preserved';

done-testing;
