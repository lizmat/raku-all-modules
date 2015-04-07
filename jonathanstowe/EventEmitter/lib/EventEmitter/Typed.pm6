# ft: perl6

use v6;

=begin pod

=begin NAME

EventEmitter::Typed - typed events

=end NAME

=begin SYNOPSIS

=begin code

   use EventEmitter::Typed;

   class MyEvent {
      has Str $.message;
   }

   class Foo does EventEmitter::Typed {
   }

   my $foo = Foo.new;

   $foo.on(MyEvent, { say $_.message });

   $foo.emit(MyEvent.new(message => "my message"));

=end code

=end SYNOPSIS

=begin DESCRIPTION

This role provides a mechanism to allow an object to consume and emit events
in a similar fashion to that of L<doc:EventEmitter::Node> but rather than
providing for named events it handles event "types" - the subscriber
provides the event type that they are interested in and the publisher simply
emits instances of those types.

It is simply a thin wrapper over the L<doc:Supply> class.

=end DESCRIPTION

=begin METHODS

The role provides two methods, one to subscribe to events and one to
publish them.

=end METHODS

=end pod

role EventEmitter::Typed:ver<v0.0.1>:auth<github:jonathanstowe> {
   has Supply %!supplies;
   has Supply $!supply;

   #|  Add a subscription to the "event type". Returning the L<doc:Tap>
   #|  object.  The callback should be a L<doc:Code> object that will receive
   #|  a single positional argument in C<$_>
   method on( Mu:U $event, &callback --> Tap ) {
      my $name = $event.^name;
      if ( not %!supplies{$name}:exists ) {
         %!supplies{$name} = self!get_supply($event);
      }
      %!supplies{$name}.tap(&callback);
   }

   method !get_supply(Mu:U $class --> Supply) {
      if not $!supply.defined {
         $!supply = Supply.new;
      }

      $!supply.grep($class);
   }

   #| Publish an event object. If there are no subscribers then this is a
   #| no-op.  The payload can be any type - it is a matter of contract
   #| between publisher and subscriber to ensure it is understood by both
   #| parties.
   method emit(Mu:D $payload --> Bool ) {
      my $rc = False;

      if ( $!supply.defined ) {
         $rc = True;
         $!supply.emit($payload);
      }
      return $rc;
   }
}
