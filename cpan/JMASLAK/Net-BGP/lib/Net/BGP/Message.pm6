use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use StrictClass;
unit class Net::BGP::Message:ver<0.0.8>:auth<cpan:JMASLAK> does StrictClass;

my %registrations := Hash[Net::BGP::Message:U,Int].new;
my %message-names := Hash[Net::BGP::Message:U,Str].new;

# Message type Nil = handle all unhandled messages
method register( Net::BGP::Message:U $class ) {
    %registrations{ $class.implemented-message-code } = $class;
    %message-names{ $class.implemented-message-name } = $class;
}

has buf8 $.data is rw;

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method raw() {
    die("Not implemented for parent class");
}

method implemented-message-code(--> Int) { … }
method implemented-message-name(--> Str) { … }

method from-raw(buf8:D $raw, Bool:D :$asn32) {
    if %registrations{ $raw[0] }:exists {
        return %registrations{ $raw[0] }.from-raw($raw, :$asn32);
    } else {
        return %registrations{Int}.from-raw($raw, :$asn32);
    }
};

method from-hash(%params is copy, :$asn32)  {
    if %params<message-code>:!exists and %params<message-name>:!exists {
        die "Could not determine message type";
    }
        
    # Normalize message-name
    if %params<message-name>:exists and %params<message-name> ~~ m/^ <[0..9]>+ $/ {
        if %params<message-code>:exists and %params<message-code> ≠ %params<message-name> {
            die("Message type and code don't agree");
        } else {
            %params<message-code> = Int(%params<message-name>);
            %params<message-name>:delete;
        }
    }

    # Fill in message type if needed
    if %params<message-code>:!exists {
        if %message-names{ %params<message-name> }:!exists {
            die("Unknown message name: %params<message-name>");
        }
        %params<message-code> = %message-names{ %params<message-name> }.implemented-message-code;
    }

    # Make sure we have agreement 
    if %params<message-name>:exists and %params<message-code>:exists {
        if %message-names{ %params<message-name> }.implemented-message-name ne %params<message-name> {
            die("Message code and type don't agree");
        }
    }

    %params<message-name>:delete; # We don't use this in children.

    return %registrations{ %params<message-code> }.from-hash( %params, :$asn32 );
};

method message-code() {
    die("Not implemented for parent class");
}

method message-name() {
    die("Not implemented for parent class");
}

=begin pod

=head1 NAME

Net::BGP::Message - BGP Message Parent Class

=head1 SYNOPSIS

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw, :$asn32 );  # Might return a child crash

=head1 DESCRIPTION

Parent class for messages.

=head1 Constructors

=head2 from-raw

Constructs a new object (likely in a subclass) for a given raw binary buffer.
You must pass C<:asn32>, a boolean that is true if the connection supports 32
bit ASNs

=head2 from-hash

Constructs a new object (likely in a subclass) for a given hash buffer.  This
module uses the C<message-name> or C<message-code> key of the hash to determine
which type of message should be returned.

=head1 Methods

=head2 message-name

Contains an integer that corresponds to the message-code.

=head2 message-code

Returns a string that describes what message type the command represents.

Currently understood types include C<OPEN>.

=head2 message-name

Contains an integer that corresponds to the message-code.

=head2 raw

Contains the raw message (not including the BGP header).

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
