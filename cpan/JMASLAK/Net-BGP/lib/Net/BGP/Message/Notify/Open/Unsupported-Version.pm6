use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Conversions;
use Net::BGP::Message::Notify::Open;

use StrictClass;
unit class Net::BGP::Message::Notify::Open::Unsupported-Version:ver<0.0.8>:auth<cpan:JMASLAK>
    is Net::BGP::Message::Notify::Open
    does StrictClass;

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

# Generic Types
method implemented-error-subcode(-->Int) { 1 }
method implemented-error-subname(-->Str) { "Unsupported-Version" }

method error-subname(-->Str) { "Unsupported-Version" }

method from-raw(buf8:D $raw where $raw.bytes == 5) {
    my $obj = self.bless(:data( buf8.new($raw) ));

    if $raw[0] ≠ 3 { # Not a notify
        die("Can only build a notification message");
    }
    if $raw[1] ≠ 2 { # Not an Open error
        die("Can only build an Open error notification message");
    }
    if $raw[2] ≠ 1 { # Not an Unsupported-Version
        die("Can only build an Unsupported Version error notification message");
    }

    # Validate the parameters parse.
    # We could probably defer this - the controller will get to it,
    # but this is safer.
    # $obj.parameters;

    return $obj;
};

method from-hash(%params is copy)  {
    # Delete unnecessary options
    if %params<message-code>:exists {
        if (%params<message-code> ≠ 3) { die("Invalid message type for NOTIFY"); }
        %params<message-code>:delete
    }
    if %params<error-code>:exists {
        if (%params<error-code> ≠ 2) { die("Invalid error type for Open"); }
        %params<error-code>:delete
    }
    if %params<error-subcode>:exists {
        if (%params<error-subcode> ≠ 1) { die("Invalid error type for Unsupported Version"); }
        %params<error-subcode>:delete
    }

    my @REQUIRED = «max-supported-version»;

    # Optional parameters
    %params<max-supported-version> //= 4;

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die %params.keys.sort.list.join(" - ");
        die("Did not provide proper options");
    }

    # Now we need to build the raw data.
    my $data = buf8.new();

    $data.append( 3 );   # Message type (NOTIFY)
    $data.append( 2 );   # Error code (Open)
    $data.append( 1 );   # Unsupported version
    $data.append( nuint16-buf8( %params<max-supported-version> ) ); # Version supported

    return self.bless(:data( buf8.new($data) ));
};

method max-supported-version(-->Int) {
    return nuint16(self.data[3..4]);
}

# Register handler
INIT { Net::BGP::Message::Notify::Open.register(Net::BGP::Message::Notify::Open::Unsupported-Version) }

=begin pod

=head1 NAME

Net::BGP::Message::Notify::Open::Unsupported-Version - Unsupported Version Open Error BGP Notify Message

=head1 SYNOPSIS

  # We create generic messages using the parent class.

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw );  # Might return a child crash

=head1 DESCRIPTION

Unsupported-Version Open error BGP Notify message type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Takes a hash with a single (optional) key - C<max-supported-version>.  If this
key isn't provided or is not defined, a max version of 4 is used.

=head1 Methods

=head2 message-name

Returns a string that describes what message type the command represents.

Currently understood types include C<Open>.

=head2 message-code

Contains an integer that corresponds to the message-code.

=head2 error-code

Error code of the notification.

=head2 error-subcode

Error subtype of the notification.

=head2 max-supported-version

Maximum supported version of BGP (16 bit unsigned integer).

=head2 raw

Returns the raw (wire format) data for this message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
