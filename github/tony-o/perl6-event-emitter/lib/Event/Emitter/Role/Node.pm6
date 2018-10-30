
use v6;

=begin pod

=begin NAME

Event::Emitter::Role::Node - Node.js like event handling

=end NAME

=begin SYNOPSIS

=begin code

   use Event::Emitter::Role::Node;

   class Foo does Event::Emitter::Role::Node {
   }

   my $foo = Foo.new;

   $foo.on('message', { say $_ });

   $foo.emit('message', 'My Message');

=end code

=end SYNOPSIS

=begin DESCRIPTION

This role provides a mechanism to allow an object to consume and emit events
in a similar fashion to that of the Node.js EventEmitter class.

It is simply a thin wrapper over the L<Event::Emitter> class.

The role is parameterised to be able to select which backend it uses, to
use the threaded (i.e. the L<Channel> ) backend, supply C<:threaded> as a
parameter to the role:

=begin code

    class Foo does Event::Emitter::Role::Node[:threaded] { ... }

=end code

=end DESCRIPTION

=begin METHODS

The role provides two methods, one to subscribe to events and one to
publish them. They take exactly the same arguments as C<on> and C<emit> in
L<Event::Emitter>.

=end METHODS

=end pod

role Event::Emitter::Role::Node[:$threaded?] {
    use Event::Emitter;

    has Event::Emitter $!emitter handles <on emit>;

    submethod BUILD {
        $!emitter = Event::Emitter.new(:threaded(so $threaded));
    }
}
