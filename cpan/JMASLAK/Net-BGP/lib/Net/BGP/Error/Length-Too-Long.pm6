use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Error;

use StrictClass;
unit class Net::BGP::Error::Length-Too-Long:ver<0.0.8>:auth<cpan:JMASLAK>
    is Net::BGP::Error
    does StrictClass;

has $.length;  # Set to the length value in the header

method message-name(-->Str) { 'Length-Too-Long' };
method message(-->Str)      { 'Length field in header is impossibly long (RFC4271)' };

=begin pod

=head1 NAME

Net::BGP::Error::Length-Too-Long - BGP Length Field Too-Long Error

=head1 SYNOPSIS

  use Net::BGP::Error::Length-Too-Long;

  my $msg = Net::BGP::Error::Length-Too-Long.new(:length(8192));

=head1 DESCRIPTION

A length (in the BGP header) formatting erorr.

The Length-Too-Long error is sent from the BGP server to the user code.  This
error is triggered when a message is received that has a length greater than
4096 octets long in the header as described in RFC4271 section 4.1.

=head1 METHODS

=head2 message-name

Contains the string C<Length-Too-Long>.

=head2 is-error

Returns True (that this is an error).

=head2 message

Returns a human-readable error message.

=head1 ATTRIBUTES

=head2 length

The length field from the header of a BGP message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
