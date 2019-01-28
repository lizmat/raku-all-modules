use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Error;

use StrictClass;
unit class Net::BGP::Error::Hold-Time-Too-Short:ver<0.0.9>:auth<cpan:JMASLAK>
    is Net::BGP::Error
    does StrictClass;

has $.hold-time;  # Set to the hold-time value in the OPEN message

method message-name(-->Str) { 'Hold-Time-Too-Short' };
method message(-->Str)      { 'Hold-Time in OPEN is too short (RFC4271)' };

=begin pod

=head1 NAME

Net::BGP::Error::Hold-Time-Too-Short - BGP OPEN Hold-Time Field Too Short Error

=head1 SYNOPSIS

  use Net::BGP::Error::Hold-Time-Too-Short;

  my $msg = Net::BGP::Error::Hold-Time-Too-Short.new(:Hold-Time(1));

=head1 DESCRIPTION

Th𝑒 Hold-Time specified in the OPEN message is non-zero and less than three
seconds.

The Hold-Time-Too-Short error is sent from the BGP server to the user code.
This error is triggered when an OPEN message is received that has a hold-time
that isn't zero and is less than three seconds, as described in RFC4271 4.1.

=head1 METHODS

=head2 message-name

Contains the string C<Hold-Time-Too-Short>.

=head2 is-error

Returns True (that this is an error).

=head2 message

Returns a human-readable error message.

=head1 ATTRIBUTES

=head2 hold-time

The hold-time field from the BGP OPEN message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
