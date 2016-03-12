#! /usr/bin/env perl6
use v6;
use Net::OSC::Message;

my Net::OSC::Message $osc-message .= new;

my $udp-listener = IO::Socket::Async.bind-udp('localhost', 7654);
my $listener-cb = $udp-listener.Supply(:bin).tap: -> $buf {
  if $buf.elems > 0 {
    my $message = $osc-message.unpackage($buf);
    say "message: { $message.path, $message.type-string, $message.args }";
  }
  #else empty packet
}

my $sender = start {
  my $udp-sender = IO::Socket::Async.udp;

  for 1..10 {
    my Net::OSC::Message $message .= new( :args<Hey 123 45.67> );
    my $sending = $udp-sender.write-to('localhost', 7654, $message.package);
    await $sending;
  }
  sleep 1;
}

await $sender;

$listener-cb.close;
