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

    is $container.remove('test-name'), True;
    is $container.remove('test-name-2'), True;

    is $container.remove('test-name'), False;
    is $container.remove('test-name-2'), False;

    is $container.get('test-name'), Nil;
    is $container.get('test-name-2'), Nil;
}, 'remove object successfully (with instance method)';

subtest {
    my $name = 'test-name';
    my $obj = 'String-Object';
    Object::Container.register($name, $obj);

    my $name2 = 'test-name-2';
    my $obj2 = 'String-Object-2';
    Object::Container.register($name2, $obj2);

    is Object::Container.remove('test-name'), True;
    is Object::Container.remove('test-name-2'), True;

    is Object::Container.remove('test-name'), False;
    is Object::Container.remove('test-name-2'), False;

    is Object::Container.get('test-name'), Nil;
    is Object::Container.get('test-name-2'), Nil;
}, 'remove object successfully (with class method; i.e. singleton)';

done-testing;

