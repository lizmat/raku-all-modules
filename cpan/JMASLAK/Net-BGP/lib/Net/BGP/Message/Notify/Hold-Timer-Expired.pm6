use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Conversions;
use Net::BGP::Message::Notify;

use StrictClass;
unit class Net::BGP::Message::Notify::Hold-Timer-Expired:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Message::Notify
    does StrictClass;

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

# Generic Types
method implemented-error-code\  (-->Int) { 4 }
method implemented-error-name\  (-->Str) { 'Hold-Timer-Expired' }
method implemented-error-subcode(-->Int) { Int }
method implemented-error-subname(-->Str) { Str }

method error-name(-->Str)    { 'Hold-Timer-Expired' };
method error-subname(-->Str) { ~ self.error-subcode }; # Undefined

method from-raw(buf8:D $raw where $raw.bytes == 3) {
    my $obj = self.bless(:data( buf8.new($raw) ));

    if $raw[0] ≠ 3 { # Not a notify
        die("Can only build a notification message");
    }
    if $raw[1] ≠ 4 { # Not a hold time expiired
        die("Can only build a Hold-Timer-Expired notification");
    }

    return $obj;
};

method from-hash(%params is copy)  {
    # Delete unnecessary option
    if %params<message-code>:exists {
        if (%params<message-code> ≠ 3) { die("Invalid message type for NOTIFY"); }
        %params<message-code>:delete
    }
    if %params<error-code>:exists {
        if (%params<error-code> ≠ 4) { die("Invalid message type for Hold-Timer-Expired"); }
        %params<error-code>:delete
    }

    my @REQUIRED = «error-subcode»;

    # Optional parameters
    %params<error-subcode> //= 0;

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    # Now we need to build the raw data.
    my $data = buf8.new();

    $data.append( 3 );   # Message type (NOTIFY)
    $data.append( 4 );
    $data.append( %params<error-subcode> );

    return self.bless(:data( buf8.new($data) ));
};

method raw() { return $.data; }

# Register handler
INIT { Net::BGP::Message::Notify.register(Net::BGP::Message::Notify::Hold-Timer-Expired) }

=begin pod

=head1 NAME

Net::BGP::Message::Notify::Hold-Timer-Expired - Hold Timer Expired BGP Notify Message

=head1 SYNOPSIS

  # We create generic messages using the parent class.

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw );  # Might return a child crash

=head1 DESCRIPTION

Hold imer Expired Notify BGP message type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

No options are required, but an C<error-subcode> can be provided if desired.

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

Returns the raw (wire format) data for this message.  Currently an empty C<buf8>.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
