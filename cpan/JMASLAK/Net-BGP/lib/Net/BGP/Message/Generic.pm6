use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Message;

use StrictClass;
unit class Net::BGP::Message::Generic:ver<0.0.9>:auth<cpan:JMASLAK>
    is Net::BGP::Message
    does StrictClass;

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method implemented-message-code(--> Int) { Int }
method implemented-message-name(--> Str) { Str }

method message-code() {
    return $.data[0];
}

method message-name() {
    return "$.message-code";
}

method from-raw(buf8:D $raw) {
    return self.bless(:data( buf8.new($raw) ));
};

method from-hash(%params)  {
    die("Not implemented for generic BGP messages");
};

method raw() { return $.data; }

# Register handler
INIT { Net::BGP::Message.register: Net::BGP::Message::Generic }

=begin pod

=head1 NAME

Net::BGP::Message::Generic - BGP Generic Message

=head1 SYNOPSIS

  # We create generic messages using the parent class.

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw );  # Might return a child crash

=head1 DESCRIPTION

Generic (undefined) BGP message type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

This simply throws an exception, since the hash format of a generic message
is not designed.

=head1 Methods

=head2 message-name

Returns a string that describes what message type the command represents.

For generic parameters, this is always a string representation of the
value of C<message-code()>.

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
