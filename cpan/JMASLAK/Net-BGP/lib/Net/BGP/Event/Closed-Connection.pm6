use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Event;

use StrictClass;
unit class Net::BGP::Event::Closed-Connection:ver<0.1.1>:auth<cpan:JMASLAK>
    is Net::BGP::Event
    does StrictClass;

has Str $.client-ip;
has Int $.client-port;

method message-name(-->Str) { 'Closed-Connection' };

method Str(-->Str) { "Closed connection { self.connection-id }" }

=begin pod

=head1 NAME

Net::BGP::Event::Closed-Connection - BGP Closed Connection Notification

=head1 SYNOPSIS

  use Net::BGP::Event::Closed-Connection;

  my $msg = Net::BGP::Event::Closed-Connection.new();

=head1 DESCRIPTION

A Closed-Connection notification.

The Closed-Connection notification is only sent from the BGP server to the user
code.  This event is triggered when a connection to the BGP listener port is
closed.

=head1 METHODS

=head2 message-name

Contains the string C<Closed-Connection>.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
