use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Conversions;
use Net::BGP::Message::Notify::Header;

use StrictClass;
unit class Net::BGP::Message::Notify::Header::Connection-Not-Syncronized:ver<0.0.8>:auth<cpan:JMASLAK>
    is Net::BGP::Message::Notify::Header
    does StrictClass;

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

# Generic Types
method implemented-error-subcode(-->Int) { 1 }
method implemented-error-subname(-->Str) { "Connection-Not-Syncronized" }

method error-subname(-->Str) { "Connection-Not-Syncronized" }

method from-raw(buf8:D $raw where $raw.bytes == 3) {
    my $obj = self.bless(:data( buf8.new($raw) ));

    if $raw[0] ≠ 3 { # Not a notify
        die("Can only build a notification message");
    }
    if $raw[1] ≠ 1 { # Not an Header error
        die("Can only build an Header error notification message");
    }
    if $raw[2] ≠ 1 { # Not a Connection Not Syncronized
        die("Can only build an Header Connection not Syncronized error notification message");
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
        if (%params<error-code> ≠ 1) { die("Invalid error type for Header"); }
        %params<error-code>:delete
    }
    if %params<error-subcode>:exists {
        if (%params<error-subcode> ≠ 1) { die("Invalid error type for Connection not Syncronized"); }
        %params<error-subcode>:delete
    }

    my @REQUIRED = «»;

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        warn %params.keys.sort.list;
        die("Did not provide proper options");
    }

    # Now we need to build the raw data.
    my $data = buf8.new();

    $data.append( 3 );   # Message type (NOTIFY)
    $data.append( 1 );   # Error code (Header)
    $data.append( 1 );   # Connection Not Syncronized

    return self.bless(:data( buf8.new($data) ));
};

method max-supported-version(-->Int) {
    return nuint16(self.data[2..3]);
}

# Register handler
INIT { Net::BGP::Message::Notify::Header.register(Net::BGP::Message::Notify::Header::Connection-Not-Syncronized) }

=begin pod

=head1 NAME

Net::BGP::Message::Notify::Header::Connection-Not-Syncronized - Connection not Syncronized Header Error BGP Notify Message

=head1 SYNOPSIS

  # We create generic messages using the parent class.

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw );  # Might return a child crash

=head1 DESCRIPTION

Connection not Syncronized Header error BGP Notify message type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Takes a hash with a no keys.

=head1 Methods

=head2 message-name

Returns a string that describes what message type the command represents.

Currently understood types include C<Header>.

=head2 message-code

Contains an integer that corresponds to the message-code.

=head2 error-code

Error code of the notification.

=head2 error-subcode

Error subtype of the notification.

=head2 raw

Returns the raw (wire format) data for this message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
