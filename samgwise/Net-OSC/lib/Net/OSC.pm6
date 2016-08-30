use v6;

unit class Net::OSC ;

=begin pod

=head1 NAME

Net::OSC - Open Sound Control for Perl6

Currently Net::OSC::Message is implimented
You can use it right now to send and receive OSC messages!

=head1 SYNOPSIS

=begin code

use Net::OSC::Message;

#Create a message object to unpack OSC Bufs
my Net::OSC::Message $osc-message .= new;

#Create a UDP listener
my $udp-listener = IO::Socket::Async.bind-udp('localhost', 7654);

#tap our udp supply and grep out any empty packets
my $listener-cb = $udp-listener.Supply(:bin).grep( *.elems > 0 ).tap: -> $buf {
  my $message = $osc-message.unpackage($buf);
  say "message: { $message.path, $message.type-string, $message.args }";
}

#Start up a thread so we can send some OSC messages to ourself
my $sender = start {
  my $udp-sender = IO::Socket::Async.udp;

  for 1..10 {
    my Net::OSC::Message $message .= new( :path("/testing/$_") :args<Hey 123 45.67> );

    #send it off
    my $sending = $udp-sender.write-to('localhost', 7654, $message.package);
    await $sending;
    sleep 0.5;
  }
  sleep 1;
}

await $sender;

$listener-cb.close;

=end code

=head1 DESCRIPTION

Net::OSC is currently planned to consist of the following classes:

=item Net::OSC
=item Net::OSC::Message - Implimented
=item Net::OSC::Bundle
=item Net::OSC::Client
=item Net::OSC::Server

Net::OSC provides message routing behaviors for the OSC Protocol, an OSC address space.
Net::OSC::Message and Net::OSC::Bundle provide a representation  and packaing of the data.
The Client and Server objects then provide higher level abstractions for network comunication.

For more details about each class, see their doc.

=head1 TODO

  =item Net::OSC::Bundle
  =item Net::OSC::Client
  =item Net::OSC::Server
  =item Additional OSC types
  =item Net::OSC - A simple interface for OSC comunications

=head1 CHANGES

=begin table
      Updated to use Numeric::Pack  | Faster and better tested Buf packing | 2016-08-30
=end table

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

method pack-message(*@args) returns Buf {

}

method unpack-message(Blob:D $message) returns List:D {

}
