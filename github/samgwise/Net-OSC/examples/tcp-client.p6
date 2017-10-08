#!/usr/bin/env perl6

use v6.c;
use lib "lib";
use Net::OSC::Transport::TCP;
use Net::OSC::Message;

sub MAIN(:$use-slip = True) {

  # Create a TCP socket
  my $tcp-client = IO::Socket::INET.new(:host<127.0.0.1>, :port(55555));

  my Net::OSC::Message $message .= new(
    :path</a>
    :args(0, 2.3456789, 'abc')
    :is64bit(False)
  );

  loop {
    if $use-slip {
      send-slip($tcp-client, $message);
    }
    else {
      send-lp($tcp-client, $message);
    }

    sleep 0.8;

    $message = $use-slip ?? recv-slip($tcp-client) !! recv-lp($tcp-client);

    my @args = $message.args;
    @args[1] += 0.00010231;
    say 'incrementing argument 1 to ', @args[1];

    $message = Net::OSC::Message.new(
      :path($message.path)
      :args(@args)
      :is64bit(False)
    );

    sleep 0.2;

  }
}
