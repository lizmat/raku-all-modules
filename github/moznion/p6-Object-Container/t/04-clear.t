use v6.c;
use Test;
use Object::Container;

subtest {
    my $container = Object::Container.new;
    my $name = 'test-name';
    my $obj = 'String-Object';
    $container.register($name, $obj);

    my $name2 = 'test-name-2';
    my $obj2 = 'String-Object-2';
    $container.register($name2, $obj2);

    $container.clear();

    is $container.get('test-name'), Nil;
    is $container.get('test-name-2'), Nil;
}, 'clear successfully (with instance method)';

subtest {
    my $name = 'test-name';
    my $obj = 'String-Object';
    Object::Container.register($name, $obj);

    my $name2 = 'test-name-2';
    my $obj2 = 'String-Object-2';
    Object::Container.register($name2, $obj2);

    Object::Container.clear();

    is Object::Container.get('test-name'), Nil;
    is Object::Container.get('test-name-2'), Nil;
}, 'clear successfully (with class method; i.e. singleton)';

done-testing;

