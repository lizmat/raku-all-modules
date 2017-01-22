use v6;

unit module Net::OSC;
use Net::OSC::Server::UDP;
use Net::OSC::Types;

=begin pod

=head1 NAME

Net::OSC - Open Sound Control for Perl6

Use the Net::OSC module to communicate with OSC applications and devices!

=head1 SYNOPSIS

=begin code :info<perl6>

use Net::OSC;

my Net::OSC::Server::UDP $server .= new(
  :listening-address<localhost>
  :listening-port(7658)
  :send-to-address<localhost> # ← Optional but makes sending to a single host very easy!
  :send-to-port(7658)         # ↲
  :actions(
    action(
      "/hello",
      sub ($msg, $match) {
        if $msg.type-string eq 's' {
          say "Hello { $msg.args[0] }!";
        }
        else {
          say "Hello?";
        }
      }
    ),
  )
);

# Send some messages!
$server.send: '/hello', :args('world', );
$server.send: '/hello', :args('lamp', );
$server.send: '/hello';

# Our routing will ignore this message:
$server.send: '/hello/not-really';

# Send a message to someone else?
$server.send: '/hello', :args('out there', ), :address<192.168.1.1>, :port(54321);

#Allow some time for our messages to arrive
sleep 0.5;

# Give our server a chance to say good bye if it needs too.
$server.close;

=end code

=head1 DESCRIPTION

Net::OSC distribution currently provides the following classes:

=item Net::OSC
=item Net::OSC::Message
=item Net::OSC::Server
=item Net::OSC::Server::UDP

Classes planned for future releases include:

=item Net::OSC::Bundle
=item Net::OSC::Server::TCP

Net::OSC imports Net::OSC::Server::UDP and the action sub to the using name space.
Net::OSC::Message provide a representation for osc messages.

See reference section below for usage details.

=head1 TODO

  =item Net::OSC::Bundle
  =item Net::OSC::Server::TCP
  =item Additional OSC types

=head1 CHANGES

=begin table
      Added Server role and UDP server  | Sugar for sending, receiving and routing messages | 2016-12-08
      Updated to use Numeric::Pack      | Faster and better tested Buf packing | 2016-08-30
=end table

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=head1 Reference

=head2 Net::OSC subroutines 

=end pod

sub EXPORT {
    {
     'Net::OSC::Server::UDP' => Net::OSC::Server::UDP,
    }
}

multi sub action(Regex $path, Callable $call-back --> ActionTuple) is export
#= Creates an action tuple for use in a server's actions list.
#= The first argument is the path, which is checked when an OSC message is received.
#= If the path of the message matches then the call back is executed.
#= The call back is passed the Net::OSC::Message object and the match object from the regular expression comparison.
{
  $($path, $call-back)
}
multi sub action(OSCPath $path, Callable $call-back --> ActionTuple) is export
#= Creates an action tuple for use in a server's actions list.
#= The string must be a valid OSC path (currently we only check for a beginning '/' character).
#=  In the future this subroutine may translate OSC path meta characters to Perl6 regular expressions.
{
  $(regex { ^ $path $ }, $call-back)
}
