use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Message;
use Net::BGP::Command;

unit class Net::BGP::Command::BGP-Message:ver<0.0.8>:auth<cpan:JMASLAK>
    is Net::BGP::Command;

has Net::BGP::Message $.message;

method message-name(-->Str) { 'BGP-Message' };

=begin pod

=head1 NAME

Net::BGP::Command::BGP-Message - BGP Message Received Notification

=head1 SYNOPSIS

  use Net::BGP::Command::BGP-Message;

  my $msg = Net::BGP::Command::BGP-Message.new();

=head1 DESCRIPTION

A BGP message send command.

The BGP message send command is sent from the user to the BGP server.  It triggers
sending the BGP message to the connected peer.

=head1 ATTRIBUTES

=head2 message

Contains the Net::BGP::Message object.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
