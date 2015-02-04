BEGIN { @*INC.push('lib') };

use IoC;
use Test;
plan 5;

class Bar {};
class Foo { has Bar $.bar; };
my $c = container 'mycont' => contains {
    service 'foo' => {
        lifecycle => 'Singleton',
        type => Foo,
        dependencies => {'bar' => 'bar'},
    };

    service 'bar' => {
        lifecycle => 'Singleton',
        'block' => sub {
            return Bar.new();
        },
    };

    service 'baz' => 'My name is Jason';
};

ok($c.fetch('foo').get);
ok($c.fetch('bar').get);

ok($c.fetch('foo').get.bar);
is($c.fetch('foo').get.bar, $c.fetch('bar').get);

is($c.fetch('baz').get, 'My name is Jason');
