use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Error;

use StrictClass;
unit class Net::BGP::Error::Marker-Format:ver<0.0.9>:auth<cpan:JMASLAK>
    is Net::BGP::Error
    does StrictClass;

method message-name(-->Str) { 'Marker-Format' };
method message(-->Str)      { 'Invalid header marker format (RFC4271)' };

=begin pod

=head1 NAME

Net::BGP::Error::Marker-Format - BGP Marker Format Error

=head1 SYNOPSIS

  use Net::BGP::Error::Marker-Format;

  my $msg = Net::BGP::Error::Marker-Format.new();

=head1 DESCRIPTION

A marker (in the BGP header) formatting erorr.

The Marker-Format error is sent from the BGP server to the user code.  This
error is triggered when a message is received that does not start with the
BGP header as described in RFC4271.

=head1 METHODS

=head2 message-name

Contains the string C<Marker-Format>.

=head2 is-error

Returns True (that this is an error).

=head2 message

Returns a human-readable error message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
