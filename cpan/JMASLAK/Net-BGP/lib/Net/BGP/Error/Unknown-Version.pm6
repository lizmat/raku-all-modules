use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Error;

use StrictClass;
unit class Net::BGP::Error::Unknown-Version:ver<0.0.8>:auth<cpan:JMASLAK>
    is Net::BGP::Error
    does StrictClass;

has $.version;  # Set to the version in the OPEN message

method message-name(-->Str) { 'Unknown-Version' };
method message(-->Str)      { 'BGP Version in OPEN is not supported' };

=begin pod

=head1 NAME

Net::BGP::Error::Unknown-Version - BGP Version field unsupported

=head1 SYNOPSIS

  use Net::BGP::Error::Unknown-Version;

  my $msg = Net::BGP::Error::Unknown-Version.new(:version(3));

=head1 DESCRIPTION

A BGP Version is unsupported.

The Unknown-Version error is sent from the BGP server to the user code.  This
error is triggered when a message is received that has a version number other
than 4, which is documented in current RFCs such as RFC4271.

=head1 METHODS

=head2 message-name

Contains the string C<Unknown-Version>.

=head2 is-error

Returns True (that this is an error).

=head2 message

Returns a human-readable error message.

=head1 ATTRIBUTES

=head2 version

The version field from the open message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
