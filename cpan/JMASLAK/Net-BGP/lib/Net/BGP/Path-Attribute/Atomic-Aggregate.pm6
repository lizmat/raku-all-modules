use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Path-Attribute;

use StrictClass;
unit class Net::BGP::Path-Attribute::Atomic-Aggregate:ver<0.0.8>:auth<cpan:JMASLAK>
    is Net::BGP::Path-Attribute
    does StrictClass;

use Net::BGP::Conversions;

# Atomic-Aggregate Types
method implemented-path-attribute-code(-->Int) { 6 }
method implemented-path-attribute-name(-->Str) { "Atomic-Aggregate" }

method path-attribute-name(-->Str:D) { "Atomic-Aggregate" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes == 3, Bool:D :$asn32) {
    if   $raw[0] +& 0x80 { die("Optional flag not valid on Atomic-Aggregate attribute") }
    if ! $raw[0] +& 0x40 { die("Transitive flag must be set on Atomic-Aggregate attribute") }
    if   $raw[0] +& 0x20 { die("Partial flag not valid on Atomic-Aggregate attribute") }
    if   $raw[0] +& 0x10 { die("Extended length flag not valid on Atomic-Aggregate attribute") }

    if   $raw[1] ≠ 6     { die("Can only create an Atomic-Aggregate attribute") }

    if ($raw.bytes - 3) ≠ $raw[2] { die("Invalid path-attribute payload length") }
    if $raw[2] ≠ 0                { die("Invalid path-attribute payload length") }

    my $obj = self.bless(:$raw, :$asn32);
    return $obj;
};

method from-hash(%params is copy, Bool:D :$asn32)  {
    my @REQUIRED = «»;

    # Remove path attributes
    if %params<path-attribute-code>:exists {
        if %params<path-attribute-code> ≠ 6 {
            die("Can only create an Atomic-Aggregate attribute");
        }
        %params<path-attribute-code>:delete;
    }
    if %params<path-attribute-name>:exists {
        if %params<path-attribute-name> ≠ 'Atomic-Aggregate' {
            die("Can only create an Atomic-Aggregate attribute");
        }
        %params<path-attribute-name>:delete;
    }

    # Check to make sure attributes are correct
    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    my $flag = 0x40;  # Transitive

    my buf8 $path-attribute = buf8.new();
    $path-attribute.append( $flag );
    $path-attribute.append( 6 );        # Atomic-Aggregate
    $path-attribute.append( 0 );        # Length

    return self.bless(:raw( $path-attribute ), :$asn32);
};

method Str(-->Str:D) { "Atomic-Aggregate" }

# Register path-attribute
INIT { Net::BGP::Path-Attribute.register(Net::BGP::Path-Attribute::Atomic-Aggregate) }

=begin pod

=head1 NAME

Net::BGP::Message::Path-Attribute::Atomic-Aggregate - BGP Atomic-Aggregate Path-Attribute Object

=head1 SYNOPSIS

  use Net::BGP::Path-Attribute::Atomic-Aggregate;

  my $cap = Net::BGP::Path-Attribute::Atomic-Aggregate.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Path-Attribute::Atomic-Aggregate.from-hash( %{ } );

=head1 DESCRIPTION

BGP Atomic Aggregate Path-Attribute Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  This requires elements with a key of
C<path-attribute-code>.  Path-Attribute code should represent the
desired path-attribute code.

It also accepts values for C<optional>, C<transitive>, and C<partial>, which
are used to populate the C<flags> field in the attribute.  These all default to
C<False> if they are not provided by the caller.

=head1 Methods

=head2 path-attribute-code

Cpaability code of the object.

=head2 path-attribute-name

The path-attribute name of the object.

=head2 flags

The value of the attribute flags (as a packed integer).

=head2 optional

True if the attribute is an optional (not well-known).

=head2 transitive

True if the attribute is a transitive attribute.

=head2 partial

True if the attribute is a partial attribute, I.E. this attribute was seen on
an intermediate router that does not understand how to process it.

=head2 extended-length

True if the attribute uses a two digit length

=head2 reserved-flags

The four flags not defined in RFC4271, represented as a packed integer (values
will be 0 through 15).

=head2 data-length

The length of the attribute's data.

=head2 data

This returns a C<buf8> containing the data in the attribute.

=head2 raw

Returns the raw (wire format) data for this path-attribute.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
