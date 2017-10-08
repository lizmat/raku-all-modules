use v6.c;
unit class Object::Container::Item:ver<0.0.2>;

has Bool $!is-initialized;
has Callable $!initializer;
has $!instance;
has Lock $!lock = Lock.new;

submethod BUILD(:$!is-initialized, :$!initializer, :$!instance) {
}

method get-instance() {
    if ($!is-initialized) {
        # If already instantiated, returns it
        return $!instance;
    }

    # Lock it to avoid duplicated instantiation from other threads.
    $!lock.lock;

    if ($!is-initialized) {
        # There is no reason to initialize (because already initialized), returns instance
        return $!instance;
    }
    $!instance = $!initializer();
    $!is-initialized = True;

    $!lock.unlock;

    return $!instance;
}

=begin pod

=head1 NAME

Object::Container::Item - A contents for L<Object::Container>

=head1 AUTHOR

moznion <moznion@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017- moznion

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

