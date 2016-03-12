#! /usr/bin/env perl6
use v6;
use Net::OSC::Message;

my $udp-sender = IO::Socket::Async.udp;

my Net::OSC::Message $message .= new(
  :path</testing>
  :args(1, 2.3456789, 'abc')
  :is64bit(False)
);
my $sending = $udp-sender.write-to('localhost', 7654, $message.package);
await $sending;
