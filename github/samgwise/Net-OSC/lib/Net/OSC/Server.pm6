use v6;

=begin pod

=head1 NAME

Net::OSC::Server - A role to facilitate a convenient platform for OSC communication.

=head1 METHODS

=begin code
method new(:$!is64bit = True)
=end code
Set :is64bit to false to force messages to be packed to 32bit types
 this option may be required to talk to some versions of Max and other old OSC implementations.

=end pod

unit role Net::OSC::Server;
use Net::OSC::Message;
use Net::OSC::Types;

has ActionTuple @!dispatcher;
has Bool        $.is64bit = True;

multi method actions( --> Seq)
#= Lists the actions managed by this server.
#= Actions are expressed as a list holding a Regex and a Callable object.
#= Upon receiving a message the server tries to match the path of the OSC message with the Regex of an action.
#= All actions with a matching Regex will be executed.
#= the Callable element of an action is called with a Net::OSC::Message and a Match object.
{
  @!dispatcher.values
}

method add-action(Regex $path, Callable $action)
#= Add an action for managing messages to the server.
#= See the actions method description above for details and the add-actions method below for the plural expression.
{
  @!dispatcher.push: $($path, $action);
}

method add-actions(*@actions)
#= Add multiple actions for managing messages to the server.
#= See the actions method description above for details.
{
  for @actions -> $action {
    die "Actions must be provided as a tuple of format: (Regex, Callable), recieved ({ $action.WHAT.perl })!" unless $action ~~ ActionTuple;
    @!dispatcher.push: $action;
  }
}

method send(OSCPath $path, *%params)
#= Send and OSC message.
#= The to add arguments to the message pass :args(...), after the OSC path string.
#= Implementing classes of the Server role may accept additional named parameters.
{
  self.transmit-message(Net::OSC::Message.new(
    :$path
    :args( (%params<args>:exists and %params<args>.defined) ?? %params<args> !! () )
    :is64bit($!is64bit)
  ))
}

method !on-message-recieved(Net::OSC::Message $message)
#= Dispatch a message to actions with an accepting path constraint
{
  for @!dispatcher -> $action {
    given $message.path {
      when $action[0] {
        $action[1]($message, $/)
      }
      default {
        next;
      }
    }
  }
}

method close()
#= Call the server's on-close method.
#= This will call the server implementations on-close hook.
{
  self!on-close();
}

method !listen()
#= Start listening for OSC messages
{ ... }

method !on-close()
#= Clean up listener and sender objects
{ ... }

multi method transmit-message(Net::OSC::Message:D $message)
#= Transmit an OSC message.
#= This method must be implemented by consuming classes.
#= implementations may add additional signatures.
#= Use this method to send a specific OSC message object instead of send (which creates one for you).
{ ... }
