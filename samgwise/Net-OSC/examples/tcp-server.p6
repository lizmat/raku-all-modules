#!/usr/bin/env perl6

use v6.c;
use lib "lib";
use Net::OSC::Transport::TCP;
use Net::OSC::Message;

sub MAIN(:$use-slip = True) {

  my $tcp-server = IO::Socket::INET.new(:localhost<127.0.0.1>, :localport(55555), :listen(True));

  while my $connection = $tcp-server.accept() {
    loop {
      my $message = $use-slip ?? recv-slip($connection) !! recv-lp($connection);

      my @args = $message.args;
      say 'incrementing argument 0 to ', ++@args[0];

      $message = Net::OSC::Message.new(
        :path($message.path)
        :args(@args)
        :is64bit(False)
      );

      if $use-slip {
        send-slip($connection, $message);
      }
      else {
        send-lp($connection, $message);
      }
    }
  }
}
