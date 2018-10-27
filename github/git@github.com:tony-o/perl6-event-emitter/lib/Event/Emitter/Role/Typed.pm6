
use v6;

=begin pod

=begin NAME

Event::Emitter::Role::Typed - typed events

=end NAME

=begin SYNOPSIS

=begin code

   use Event::Emitter::Role::Typed;

   class MyEvent {
      has Str $.message;
   }

   class Foo does Event::Emitter::Role::Typed {
   }

   my $foo = Foo.new;

   $foo.on(MyEvent, { say $_.message });

   $foo.emit(MyEvent.new(message => "my message"));

=end code

=end SYNOPSIS

=begin DESCRIPTION

This role provides a mechanism to allow an object to consume and emit events
in a similar fashion to that of L<Event::Emitter::Role::Node> but rather than
providing for named events it handles event "types" - the subscriber
provides the event type that they are interested in and the publisher simply
emits instances of those types.

It is simply a thin wrapper over the L<Event::Emitter> class.

The role is parameterised to be able to select which backend it uses, to
use the threaded (i.e. the L<Channel> ) backend, supply C<:threaded> as a
parameter to the role:

=begin code

    class Foo does Event::Emitter::Role::Typed[:threaded] { ... }

=end code

=end DESCRIPTION

=begin METHODS

The role provides two methods, one to subscribe to events and one to
publish them.

=end METHODS

=end pod
role Event::Emitter::Role::Typed[:$threaded?] {
    use Event::Emitter;

    has Event::Emitter $!emitter;

    submethod BUILD {
        $!emitter = Event::Emitter.new(:threaded(so $threaded));
    }

    method on(Mu:U $type, Callable $handler) {
        $!emitter.on(-> $event { $event ~~ $type}, $handler);
    }

    method emit(Mu:D $payload) {
        $!emitter.emit($payload.WHAT, $payload);
    }
}
