use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Path-Attribute;

use StrictClass;
unit class Net::BGP::Path-Attribute::Cluster-List:ver<0.0.9>:auth<cpan:JMASLAK>
    is Net::BGP::Path-Attribute
    does StrictClass;

use Net::BGP::Conversions;
use Net::BGP::IP;

# Cluster-List Types
method implemented-path-attribute-code(-->Int) { 10 }
method implemented-path-attribute-name(-->Str) { "Cluster-List" }

method path-attribute-name(-->Str:D) { "Cluster-List" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 3, :$asn32) {
    if ! $raw[0] +& 0x80 { die("Optional flag must be set on Cluster-List attribute") }
    if   $raw[0] +& 0x40 { die("Transitive flag not valid on Cluster-List attribute") }
    if   $raw[0] +& 0x20 { die("Partial flag not valid on Cluster-List attribute") }

    if $raw[1] ≠ 10 { die("Can only create a Cluster-List attribute") }

    my $len;
    if $raw[0] +& 0x10 {
        $len = nuint16($raw[2], $raw[3]);
        if $raw.bytes ≠ ($len + 4) { die("Cluster-List attribute has bad payload length") }
    } else {
        $len = $raw[2];
        if $raw.bytes ≠ ($len + 3) { die("Cluster-List attribute has bad payload length") }
    }

    my $obj = self.bless(:$raw, :$asn32);
    return $obj;
};

method from-hash(%params is copy, Bool:D :$asn32)  {
    my @REQUIRED = «cluster-list»;

    # Remove path attributes
    if %params<path-attribute-code>:exists {
        if %params<path-attribute-code> ≠ 10 {
            die("Can only create an Cluster-List attribute");
        }
        %params<path-attribute-code>:delete;
    }
    if %params<path-attribute-name>:exists {
        if %params<path-attribute-name> ≠ 'Cluster-List' {
            die("Can only create an Cluster-List attribute");
        }
        %params<path-attribute-name>:delete;
    }

    my @clusters = %params<cluster-list>.split(/\s+/);
    
    my $cluster-list-buf = buf8.new;
    for @clusters -> $cluster { $cluster-list-buf.append: ipv4-to-buf8($cluster) }

    # Check to make sure attributes are correct
    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    if $cluster-list-buf.bytes > 65535 { die "Value is longer than 65535 bytes" }

    my $flag = 0x80;  # Optional, Non-Transitive
    if $cluster-list-buf.bytes > 255 { $flag += 0x10 }  # Extended length?

    my buf8 $path-attribute = buf8.new();
    $path-attribute.append( $flag );
    $path-attribute.append( 10 );

    if $cluster-list-buf.bytes > 255 {
        $path-attribute.append( nuint16-buf8( $cluster-list-buf.bytes ) );
    } else {
        $path-attribute.append( $cluster-list-buf.bytes );
    }
    $path-attribute.append( $cluster-list-buf );

    return self.bless( :raw( $path-attribute ), :$asn32 );
};

method cluster-list(-->Array[Str:D]) {
    my Str:D @return;

    my $cluster-buf;
    if $.raw[0] +& 0x10 { # XXX Should check length field, but we skip it
        $cluster-buf = buf8.new: $.raw[4..*];
    } else {
        $cluster-buf = buf8.new: $.raw[3..*];
    }

    for ^( ($cluster-buf.bytes / 4).Int ) -> $i {
        @return.push: int-to-ipv4( nuint32( buf8.new($cluster-buf[$i*4..($i*4+3)]) ) );
    }

    return @return;
}

method Str(-->Str:D) { "Cluster-List=" ~ self.cluster-list.join(' ') }

# Register path-attribute
INIT { Net::BGP::Path-Attribute.register(Net::BGP::Path-Attribute::Cluster-List) }

=begin pod

=head1 NAME

Net::BGP::Message::Path-Attribute::Cluster-List - BGP Cluster-List Path-Attribute Object

=head1 SYNOPSIS

  use Net::BGP::Path-Attribute::Cluster-List;

  my $cap = Net::BGP::Path-Attribute::Cluster-List.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Path-Attribute::Cluster-List.from-hash(
    cluster-list => '192.0.2.1 192.0.2.2'
  );

=head1 DESCRIPTION

BGP Cluster-List Path-Attribute Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  Thakes a hash with a single key,
C<cluster-list>, a string that contains space-seperated human-readable IP
addresses.

=head1 Methods

=head2 path-attribute-code

Capability code of the object.

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

=head2 cluster-list

Returns an array of strings representing each cluster member in the cluster
list.

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
