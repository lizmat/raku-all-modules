#! /usr/bin/env perl6
use v6;
use Net::OSC::Message;

#Create a message object to unpack OSC Bufs
my Net::OSC::Message $osc-message .= new;

#Create a UDP listener
my $udp-listener = IO::Socket::Async.bind-udp('localhost', 7654);

# tap our udp supply and grep out any empty packets
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
