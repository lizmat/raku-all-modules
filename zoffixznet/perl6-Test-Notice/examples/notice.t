use lib <lib ../lib>;
use Test;
use Test::Notice;

subtest {
    notice 'Install Foo::Bar::Baz for extra awesome features!';
}, 42;

ok 1;
done-testing;
