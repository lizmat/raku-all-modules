use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Conversions;
use Net::BGP::Message::Notify;

use StrictClass;
unit class Net::BGP::Message::Notify::Generic:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Message::Notify
    does StrictClass;

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

# Generic Types
method implemented-error-code\  (-->Int) { Int }
method implemented-error-name\  (-->Str) { Str }
method implemented-error-subcode(-->Int) { Int }
method implemented-error-subname(-->Str) { Str }

method error-name(-->Str)    { Str }; # Undefined
method error-subname(-->Str) { Str }; # Undefined

method from-raw(buf8:D $raw where $raw.bytes ≥ 3) {
    my $obj = self.bless(:data( buf8.new($raw) ));

    if $raw[0] ≠ 3 { # Not a notify
        die("Can only build a notification message");
    }

    # Validate the parameters parse.
    # We could probably defer this - the controller will get to it,
    # but this is safer.
    # $obj.parameters;

    return $obj;
};

method from-hash(%params is copy)  {
    # Delete unnecessary option
    if %params<message-code>:exists {
        if (%params<message-code> ≠ 3) { die("Invalid message type for NOTIFY"); }
        %params<message-code>:delete
    }

    my @REQUIRED = «error-code error-subcode raw-data»;

    # Optional parameters
    %params<raw-data> //= buf8.new;

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    # Now we need to build the raw data.
    my $data = buf8.new();

    $data.append( 3 );   # Message type (NOTIFY)
    $data.append( %params<error-code> );
    $data.append( %params<error-subcode> );
    $data.append( %params<raw-data> );

    return self.bless(:data( buf8.new($data) ));
};

method raw() { return $.data; }

method Str(-->Str:D) {
    "NOTIFY Error={ self.error-code } Subtype={ self.error-subcode }"
}

# Register handler
INIT { Net::BGP::Message::Notify.register(Net::BGP::Message::Notify::Generic) }

=begin pod

=head1 NAME

Net::BGP::Message::Notify::Generic - Generic BGP Notify Message

=head1 SYNOPSIS

  # We create generic messages using the parent class.

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw );  # Might return a child crash

=head1 DESCRIPTION

Generic Notify BGP message type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

This simply throws an exception, since the hash format of a generic message
is not designed.

=head1 Methods

=head2 message-type

Returns a string that describes what message type the command represents.

Currently understood types include C<OPEN>.

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
