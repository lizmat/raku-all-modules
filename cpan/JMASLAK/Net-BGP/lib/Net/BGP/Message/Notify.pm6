use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Conversions;
use Net::BGP::Message;

use StrictClass;
unit class Net::BGP::Message::Notify:ver<0.0.9>:auth<cpan:JMASLAK>
    is Net::BGP::Message
    does StrictClass;

my %error-codes := Hash[Net::BGP::Message::Notify:U,Int].new;
my %error-names := Hash[Net::BGP::Message::Notify:U,Str].new;

method implemented-message-code(--> Int) { 3 }
method implemented-message-name(--> Str) { "NOTIFY" }

method implemented-error-code\  (--> Int) { … }
method implemented-error-name\  (--> Str) { … }
method implemented-error-subcode(--> Int) { … }
method implemented-error-subname(--> Str) { … }

method register( Net::BGP::Message::Notify:U $class -->Nil) {
    %error-codes{ $class.implemented-error-code } = $class;
    %error-names{ $class.implemented-error-name } = $class;
}

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

has buf8 $.data is rw;

method message-code() { 3 }
method message-name() { "NOTIFY" }

# Stuff unique to NOTIFY
method error-code(-->Int)    { $.data[1] }
method erorr-name(-->Str)    { … }
method error-subcode(-->Int) { $.data[2] }
method erorr-subname(-->Str) { … }

method payload(-->buf8) {
    if $.data.bytes > 3 {
        return $.data.subbuf(3, $.data.bytes - 3);
    } else {
        return buf8.new();
    }
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 3) {
    if $raw[0] ≠ 3 { # Not notify
        die("Can only build a notification message");
    }

    if %error-codes{ $raw[1] }:exists {
        return %error-codes{ $raw[1] }.from-raw($raw);
    } else {
        return %error-codes{ Int }.from-raw($raw);
    }
};

method from-hash(%params is copy)  {
    # Delete unnecessary option
    if %params<message-code>:exists {
        if (%params<message-code> ≠ 3) { die("Invalid message type for NOTIFY"); }
        %params<message-code>:delete
    }

    # Get code from name
    if %params<error-name>:exists {
        if %error-names{ %params<error-name> }:!exists {
            die("error-name does not exist");
        }

        if %params<error-code>:exists {
            if %params<error-code> ≠ %error-names{ %params<error-names> }.implemented-error-code {
                die("Message code and name do not agree");
            }
        } else {
            %params<error-code> = %error-names{ %params<error-name> }.implemented-error-code;
        }

        %params<error-name>:delete;
    }

    if %error-codes{ %params<error-code> }:exists {
        return %error-codes{ %params<error-code> }.from-hash(%params);
    } else {
        return %error-codes{ Int }.from-hash(%params);
    }
};

method raw() { return $.data; }

# Register handler
INIT { Net::BGP::Message.register: Net::BGP::Message::Notify }

=begin pod

=head1 NAME

Net::BGP::Message::Notify - BGP Notify Message

=head1 SYNOPSIS

  # We create generic messages using the parent class.

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw );  # Might return a child crash

=head1 DESCRIPTION

Notify BGP message type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

This simply throws an exception, since the hash format of a generic message
is not designed.

=head1 Methods

=head2 message-name

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
