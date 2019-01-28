use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Message;
use Net::BGP::Event;

use StrictClass;
unit class Net::BGP::Event::BGP-Message:ver<0.0.9>:auth<cpan:JMASLAK>
    is Net::BGP::Event
    does StrictClass;

has Net::BGP::Message $.message;

method message-name(-->Str) { 'BGP-Message' };

method Str(-->Str) {
    "{ self.connection-id } BGP { self.message.Str }";
}

=begin pod

=head1 NAME

Net::BGP::Event::BGP-Message - BGP Message Received Notification

=head1 SYNOPSIS

  use Net::BGP::Event::BGP-Message;

  my $msg = Net::BGP::Event::BGP-Message.new();

=head1 DESCRIPTION

A BGP message receipt notification.

The BGP message notificationis only sent from the BGP server to the user
code.  This event is triggered when a BGP message is received from the peer.

=head1 ATTRIBUTES

=head2 message

Contains the Net::BGP::Message object.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
