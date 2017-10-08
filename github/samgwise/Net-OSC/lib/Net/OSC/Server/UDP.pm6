use v6;
use Net::OSC::Server;

=begin pod

=head1 NAME

Net::OSC::Server::UDP - A convenient platform for OSC communication over UDP.

 Does Net::OSC::Server - look there for additional methods.

=head1 METHODS

=begin code
method new(
  Bool :$!is64bit = True,
  Str :listening-address,
  Int :listening-port,
  Str :send-to-address,
  Int :send-to-port,
)
=end code
Set :is64bit to false to force messages to be packed to 32bit types
 this option may be required to talk to some versions of Max and other old OSC implementations.
The send-to-* parameters are not required but allow for convenient semantics if you are only communicating with a single host.

=end pod

unit class Net::OSC::Server::UDP does Net::OSC::Server;
use Net::OSC::Message;
use Net::OSC::Types;

has IO::Socket::Async $!udp-listener;
has Tap               $!listener;
has IO::Socket::Async $!udp-sender;
has Str               $.listening-address;
has Int               $.listening-port;
has Str               $.send-to-address is rw;
has Int               $.send-to-port is rw;

submethod BUILD(:$!listening-address, :$!listening-port, :$!send-to-address, :$!send-to-port, :$!is64bit = True, :@actions) {
  self.add-actions(@actions);
  self!listen;
}

method send(OSCPath $path, *%params)
#= Send a UDP message to a specific host and port.
#= This method extends the Net::OSC::Server version and adds the :address and :port
#=  Named arguments to support UDP message sending.
#= If :address or :port are not provided the Server's relevant send-to-* attribute will be used instead.
{
  if %params<address>:exists or %params<port>:exists {
    self.transmit-message(
      Net::OSC::Message.new(
        :$path
        :args( (%params<args>:exists and %params<args>.defined) ?? %params<args> !! () )
        :is64bit($!is64bit)
      ),
      (%params<address>:exists ?? %params<address> !! $!send-to-address),
      (%params<port>:exists    ?? %params<port>    !! $!send-to-port)
    )
  }
  else {
    self.transmit-message(
      Net::OSC::Message.new(
        :$path
        :args( (%params<args>:exists and %params<args>.defined) ?? %params<args> !! () )
        :is64bit($!is64bit)
      )
    )
  }
}

method !listen()
#= Start listening for OSC messages
{
  $!udp-listener  .= bind-udp($!listening-address, $!listening-port);
  $!udp-sender    .= udp;

  $!listener = $!udp-listener.Supply(:bin).grep( *.elems > 0 ).tap: -> $buf {
    self!on-message-recieved: Net::OSC::Message.unpackage($buf)
  }
}

method !on-close()
#= Clean up listener and sender objects
{
  $!listener.close;
}

multi method transmit-message(Net::OSC::Message:D $message)
#= Transmit an OSC message.
#= This implementation will send the provided message to the server's send-to-* attributes.
{
  await $!udp-sender.write-to($!send-to-address, $!send-to-port, $message.package);
}

multi method transmit-message(Net::OSC::Message:D $message, Str $address, Int $port)
#= Transmit an OSC message to a specified host and port.
#= This implementation sends the provided message to the specified address and port.
{
  await $!udp-sender.write-to($address, $port, $message.package);
}
