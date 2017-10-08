use v6.c;
unit class Object::Container:ver<0.0.2>;

use Object::Container::Item;

has Hash $!container;

multi method register(Str:D $name, Any:D $object) {
    self!instance!put(
        $name,
        Object::Container::Item.new(
            is-initialized => True,
            initializer    => Nil,
            instance       => $object,
        )
    );
}

multi method register(Str:D $name, Callable:D $initializer) {
    self!instance!put(
        $name,
        Object::Container::Item.new(
            is-initialized => False,
            initializer    => $initializer,
            instance       => Nil,
        )
    );
}

method get(Str:D $name) returns Any {
    return self!instance!find($name)
}

method remove(Str:D $name) returns Bool {
    return self!instance!remove($name);
}

method clear() {
    self!instance!clear;
}

method !put($name, Object::Container::Item $item) {
    $!container{$name} = $item;
}

method !find($name) returns Any {
    my $obj = $!container{$name};
    if (!$obj.defined) {
        return Nil;
    }

    return $obj.get-instance;
}

method !remove($name) returns Bool {
    return $!container{$name}:delete.defined;
}

method !clear() {
    $!container = Hash.new;
}

# Returns instance of this
method !instance() returns Object::Container {
    if self.defined {
        return self;
    }

    # self is undefined; i.e. called as class method.
    # When called as class method, it handles as singleton.
    state $singleton //= self.new;
    return $singleton;
}

=begin pod

=head1 NAME

Object::Container - A simple container for object for perl6

=head1 SYNOPSIS

=head2 Instance method

  use Object::Container;

  my $container = Object::Container.new;

  $container.register('obj1', $obj1);
  $container.register('obj2', $obj2);

  $container.get('obj1');        # <= equals $obj1
  $container.get('obj2');        # <= equals $obj2
  $container.get('not-existed'); # <= equals Nil

=head2 Class method (singleton)

  use Object::Container;

  Object::Container.register('obj1', $obj1);
  Object::Container.register('obj2', $obj2);

  Object::Container.get('obj1');        # <= equals $obj1
  Object::Container.get('obj2');        # <= equals $obj2
  Object::Container.get('not-existed'); # <= equals Nil

=head1 DESCRIPTION

Object::Container is a simple container for object. A simple DI mechanism can be implemented easily by using this module.
This module provides following features;

=item Register object to container
=item Find object from container
=item Remove registered object from container
=item Clear container

=head1 METHODS

=head2 C<register(Str:D $name, Any:D $object)>

Registers the instantiated object with name in the container.

=head2 C<register(Str:D $name, Callable:D $initializer)>

Registers the C<Callable> as initializer to instantiate the object with the name in the container.
This method instantiates the object with calling C<Callable>.
This is a B<lazy> way to instantiate; it means it defers instantiation (i.e. calling C<Callable>) until C<get(...)> is invoked.

    my $container = Object::Container.new;
    my $initializer = sub {
        # Reach here when `$container.get()` is called (only at once)
        return $something;
    };
    $container.register('obj-name', $initializer);

=head2 C<get(Str:D $name) returns Any>

Finds the registered object from the container by the name and return it.
If the object is missing, it returns C<Nil>.

=head2 C<remove(Str:D $name) returns Bool>

Removes the registered object from the container by the name.
It returns whether the registered object was existed in the container or not.

=head2 C<clear()>

Clears the container.
In other words, it rewinds the container to its initial state.

=head1 Singleton pattern

If you use this module with class method (e.g. C<Object::Container.register(...)>), this module handles the container as singleton object.

=head1 AUTHOR

moznion <moznion@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017- moznion

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

