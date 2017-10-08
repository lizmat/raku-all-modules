use v6.c;
use Test;
use Object::Container;

subtest {
    my $container = Object::Container.new;
    my $name = 'test-name';
    my $obj = 'String-Object';
    my $initializer = sub {
        return $obj;
    };
    $container.register($name, $initializer);

    my $name2 = 'test-name-2';
    my $obj2 = 'String-Object-2';
    my $initializer2 = sub {
        return $obj2;
    };
    $container.register($name2, $initializer2);

    is $container.get($name), $obj;
    is $container.get($name2), $obj2;
}, 'register object and lazily instantiate successfully (with instance method)';

subtest {
    my $name = 'test-name';
    my $obj = 'String-Object';
    Object::Container.register($name, $obj);
    is Object::Container.get($name), $obj;

    my $name2 = 'test-name-2';
    my $obj2 = 'String-Object-2';
    Object::Container.register($name2, $obj2);
    is Object::Container.get($name2), $obj2;
}, 'register object and lazily instantiate successfully (with class method; i.e. singleton)';

done-testing;

