# ft: perl6

use v6;

=begin pod

=begin NAME

EventEmitter::Node - Node.js like event handling

=end NAME

=begin SYNOPSIS

=begin code

   use EventEmitter::Node;

   class Foo does EventEmitter::Node {
   }

   my $foo = Foo.new;

   $foo.on('message', { say $_ });

   $foo.emit('message', 'My Message');

=end code

=end SYNOPSIS

=begin DESCRIPTION

This role provides a mechanism to allow an object to consume and emit events
in a similar fashion to that of the Node.js EventEmitter class.

It is simply a thin wrapper over the L<doc:Supply> class.

=end DESCRIPTION

=begin METHODS

The role provides two methods, one to subscribe to events and one to
publish them.

=end METHODS

=end pod

role EventEmitter::Node:ver<v0.0.1>:auth<github:jonathanstowe> {
   has Supply %!supplies;

   #|  Add a subscription to the named "event". Returning the L<doc:Tap>
   #|  object.  The callback should be a L<doc:Code> object that will receive
   #|  a single positional argument in C<$_>
   method on( Str $event, &callback --> Tap ) {
      if ( not %!supplies{$event}:exists ) {
         %!supplies{$event} = Supply.new
      }
      %!supplies{$event}.tap(&callback);
   }

   #| Publish the named event. If there are no subscribers then this is a
   #| no-op.  The payload can be any type - it is a matter of contract
   #| between publisher and subscriber to ensure it is understood by both
   #| parties.
   method emit(Str $event, Any $payload --> Bool ) {
      my $rc = False;

      if ( %!supplies{$event}:exists ) {
         $rc = True;
         %!supplies{$event}.emit($payload);
      }
      return $rc;
   }
}
