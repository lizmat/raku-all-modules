use v6;

#
# Copyright © 2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Path-Attribute;

use StrictClass;
unit class Net::BGP::Path-Attribute::Aggregator:ver<0.0.8>:auth<cpan:JMASLAK>
    is Net::BGP::Path-Attribute
    does StrictClass;

use Net::BGP::Conversions;
use Net::BGP::IP;

# Aggregator Types
method implemented-path-attribute-code(-->Int) { 7 }
method implemented-path-attribute-name(-->Str) { "Aggregator" }

method path-attribute-name(-->Str:D) { "Aggregator" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes == 9|11, Bool:D :$asn32) {
    if ! $raw[0] +& 0x80 { die("Optional flag must be set on Origin attribute") }
    if ! $raw[0] +& 0x40 { die("Transitive flag must be set on Origin attribute") }
    if   $raw[0] +& 0x20 { die("Partial flag not valid on Origin attribute") }
    if   $raw[0] +& 0x10 { die("Extended length flag not valid on Origin attribute") }

    if   $raw[1] ≠ 7     { die("Can only create an Origin attribute") }

    if ($raw.bytes - 3) ≠ $raw[2] { die("Invalid path-attribute payload length") }
    if  $asn32 && $raw[2] ≠ 8     { die("Invalid path-attribute payload length") }
    if !$asn32 && $raw[2] ≠ 6     { die("Invalid path-attribute payload length") }

    my $obj = self.bless(:$raw, :$asn32);
    return $obj;
};

method from-hash(%params is copy, Bool:D :$asn32)  {
    my @REQUIRED = «asn ip»;

    # Remove path attributes
    if %params<path-attribute-code>:exists {
        if %params<path-attribute-code> ≠ 7 {
            die("Can only create an Aggregator attribute");
        }
        %params<path-attribute-code>:delete;
    }
    if %params<path-attribute-name>:exists {
        if %params<path-attribute-name> ≠ 'Aggregator' {
            die("Can only create an Aggregator attribute");
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
    $path-attribute.append( 7 );        # Aggregator

    if $asn32 {
        if %params<asn> !~~ ^(2³²) { die("Invalid ASN provided") }

        $path-attribute.append( 8 );
        $path-attribute.append( nuint32-buf8(%params<asn>) );
    } else {
        if %params<asn> !~~ ^(2¹⁶) { die("Invalid ASN provided") }

        $path-attribute.append( 6 );
        $path-attribute.append( nuint16-buf8(%params<asn>) );
    }
    $path-attribute.append( nuint32-buf8(%params<ip>) );

    return self.bless(:raw( $path-attribute ), :$asn32);
};

method asn(-->Int:D) {
    if $.asn32 {
        return nuint32($.raw[3..6]);
    } else {
        return nuint16($.raw[3..4]);
    }
}

method ip(-->Str:D) {
    if $.asn32 {
        return buf8-to-ipv4($.raw.subbuf(7,10).list);
    } else {
        return buf8-to-ipv4($.raw.subbuf(5,8).list);
    }
}

method Str(-->Str:D) { "Aggregator: ASN={ self.asn } ID={ self.ip }" };

# Register path-attribute
INIT { Net::BGP::Path-Attribute.register(Net::BGP::Path-Attribute::Aggregator) }

=begin pod

=head1 NAME

Net::BGP::Message::Path-Attribute::Aggregator - BGP Aggregator Path-Attribute Object

=head1 SYNOPSIS

  use Net::BGP::Path-Attribute::Aggregator;

  my $cap = Net::BGP::Path-Attribute::Aggregator.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Path-Attribute::Aggregator.from-hash(
    %{ asn => 65000, ip => '192.0.2.1' }
  );

=head1 DESCRIPTION

BGP Path-Attribute Aggregator Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  This requires elements with keys of
C<asn> and C<ip>, which represent the aggregating ASN and aggregating BGP ID
in this path attribute.

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

=head2 asn

Returns the aggregator's ASN.

=head2 ip

Returns the aggregator's IP.

=head2 data-length

The length of the attribute's data.

=head2 data

This returns a C<buf8> containing the data in the attribute.

=head2 raw

Returns the raw (wire format) data for this path-attribute.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
