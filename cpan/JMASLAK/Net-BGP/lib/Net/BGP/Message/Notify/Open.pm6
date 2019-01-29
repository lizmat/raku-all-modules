use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Conversions;
use Net::BGP::Message::Notify;

use StrictClass;
unit class Net::BGP::Message::Notify::Open:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Message::Notify
    does StrictClass;

my %error-subcodes := Hash[Net::BGP::Message::Notify::Open:U,Int].new;
my %error-subnames := Hash[Net::BGP::Message::Notify::Open:U,Str].new;

# Generic Types
method implemented-error-code\  (-->Int) { 2 }
method implemented-error-name\  (-->Str) { "Open" }
method implemented-error-subcode(-->Int) { … }
method implemented-error-subname(-->Str) { … }

method error-name(-->Str) { "Open" }

method register( Net::BGP::Message::Notify::Open:U $class -->Nil) {
    %error-subcodes{ $class.implemented-error-subcode } = $class;
    %error-subnames{ $class.implemented-error-subname } = $class;
}

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 3) {
    if $raw[0] ≠ 3 { # Not notify
        die("Can only build a notification message");
    }
    if $raw[1] ≠ 2 { # Not Open Error
        die("Can only build an Open error notification message");
    }

    if %error-subcodes{ $raw[2] }:exists {
        return %error-subcodes{ $raw[2] }.from-raw($raw);
    } else {
        return %error-subcodes{ Int }.from-raw($raw);
    }
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

    # Get code from name
    if %params<error-subname>:exists {
        if %error-subnames{ %params<error-subname> }:!exists {
            die("error-subname does not exist");
        }

        if %params<error-subcode>:exists {
            if %params<error-subcode> ≠ %error-subnames{ %params<error-subnames> }.implemented-error-subcode {
                die("Message subcode and name do not agree");
            }
        } else {
            %params<error-subcode> = %error-subnames{ %params<error-subname> }.implemented-error-subcode;
        }

        %params<error-subname>:delete;
    }

    if %error-subcodes{ %params<error-subcode> }:exists {
        return %error-subcodes{ %params<error-subcode> }.from-hash(%params);
    } else {
        return %error-subcodes{ Int }.from-hash(%params);
    }
}

# Register handler
INIT { Net::BGP::Message::Notify.register(Net::BGP::Message::Notify::Open) }

=begin pod

=head1 NAME

Net::BGP::Message::Notify::Open - Open BGP Notify Message

=head1 SYNOPSIS

  # We create generic messages using the parent class.

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw );  # Might return a child crash

=head1 DESCRIPTION

Open Notify BGP message type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

This simply throws an exception, since the hash format of a generic message
is not designed.

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

=head2 raw

Returns the raw (wire format) data for this message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
