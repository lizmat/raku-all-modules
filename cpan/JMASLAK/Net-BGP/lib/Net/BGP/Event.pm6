use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

unit class Net::BGP::Event:ver<0.0.8>:auth<cpan:JMASLAK>;

has Int $.connection-id;
has Str $.peer;

has Int:D $.creation-date = DateTime.now.posix;

method message-name(-->Str) { 'NOOP' };
method is-error(-->Bool)    { False  };

=begin pod

=head1 NAME

Net::BGP::Event - BGP Server Event Superclass

=head1 SYNOPSIS

  use Net::BGP::Event;

  my $msg = Net::BGP::Event.new( :message-name<NOOP> );

=head1 DESCRIPTION

Parent class for messages (notifications) used for communication from the BGP
server code to the user code.

=head1 ATTRIBUTES

=head2 connection-id

This contains the appropriate connection ID associated with the notification.

=head2 peer

This contains the IP address of the peer.

=head2 creation-date

The date/time in Posix format when this object was created.

=head1 METHODS

=head2 message-name

Contains a string that describes what message type the notification represents.

=head2 is-error

Returns true or false based on whether this notification represents an error.
It defaults to False in the parent class.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
