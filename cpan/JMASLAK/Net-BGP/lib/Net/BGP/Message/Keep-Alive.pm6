use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Message;

use StrictClass;
unit class Net::BGP::Message::Keep-Alive:ver<0.0.9>:auth<cpan:JMASLAK>
    is Net::BGP::Message
    does StrictClass;

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method implemented-message-code(--> Int) { 4 }
method implemented-message-name(--> Str) { "KEEP-ALIVE" }

method message-code() { 4 }
method message-name() { "KEEP-ALIVE" }

method from-raw(buf8:D $raw) {
    return self.bless(:data( buf8.new($raw) ));
};

method from-hash(%params is copy)  {
    my @REQUIRED = «»;

    # Delete unnecessary option
    if %params<message-code>:exists {
        if (%params<message-code> ≠ 4) { die("Invalid message type for Keep-Alive"); }
        %params<message-code>:delete
    }

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    # Now we need to build the raw data.
    my $data = buf8.new();

    $data.append( 4 );   # Message type (KEEP-ALIVE)

    return self.bless(:data( buf8.new($data) ));
};

method raw() { return $.data; }

method Str(-->Str) { "KEEP-ALIVE" }

# Register handler
INIT { Net::BGP::Message.register: Net::BGP::Message::Keep-Alive }

=begin pod

=head1 NAME

Net::BGP::Message::Keep-Alive - BGP Keep-Alive Message

=head1 SYNOPSIS

  # We create keep-alive messages using the parent class.

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw );  # Might return a child crash

=head1 DESCRIPTION

Keep-Alive BGP message type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Builds a keep-alive message from a hash. Note that an empty hash is expected
here to maintain compatibility with the interfaces for other C<Net::BGP::Message>
subclasses.

=head1 Methods

=head2 message-name

Returns a string that describes what message type the command represents.

=head2 message-code

Contains an integer that corresponds to the message-code.

=head2 raw

Returns the raw (wire format) data for this message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
