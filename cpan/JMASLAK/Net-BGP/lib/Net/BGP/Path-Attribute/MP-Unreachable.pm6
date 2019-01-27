use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Path-Attribute;

use StrictClass;
unit class Net::BGP::Path-Attribute::MP-Unreachable:ver<0.0.8>:auth<cpan:JMASLAK>
    is Net::BGP::Path-Attribute
    does StrictClass;

use Net::BGP::AFI :ALL;
use Net::BGP::CIDR;
use Net::BGP::Conversions;
use Net::BGP::IP;
use Net::BGP::SAFI :ALL;

# MP-Withdrawn Types
method implemented-path-attribute-code(-->Int) { 15 }
method implemented-path-attribute-name(-->Str) { "MP-Unreachable" }

method path-attribute-name(-->Str:D) { "MP-Unreachable" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 3, :$asn32) {
    if ! $raw[0] +& 0x80 { die("Optional flag must be set on MP-Unreachable attribute") }
    if   $raw[0] +& 0x40 { die("Transitive flag not valid on MP-Unreachable attribute") }
    if   $raw[0] +& 0x20 { die("Partial flag not valid on MP-Unreachable attribute") }

    if $raw[1] ≠ 15 { die("Can only create a MP-Unreachable attribute") }

    my $obj = self.bless(:$raw, :$asn32);
    return $obj;
};

method from-hash(%params is copy, Bool:D :$asn32)  {
    my @REQUIRED = «address-family next-hop withdrawn»;

    # Remove path attributes
    if %params<path-attribute-code>:exists {
        if %params<path-attribute-code> ≠ 15 {
            die("Can only create an MP-Unreachable attribute");
        }
        %params<path-attribute-code>:delete;
    }
    if %params<path-attribute-name>:exists {
        if %params<path-attribute-name> ≠ 'MP-Unreachable' {
            die("Can only create an MP-Unreachable attribute");
        }
        %params<path-attribute-name>:delete;
    }

    # Check to make sure attributes are correct
    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    if %params<address-family> ne 'ipv6' { die("Unknown address family") }

    my $withdrawn = buf8.new;
    for %params<withdrawn>.split(/\s+/) -> $cidr {
        my @parts = $cidr.split('/');
        my $newbuf = ipv6-to-buf8(@parts[0], :bits(@parts[1].Int));
        $withdrawn.append(@parts[1].Int);
        $withdrawn.append($newbuf);
    }

    my $flag = 0x80;  # Optional, Non-Transitive
    if $withdrawn.bytes > 255 { $flag += 0x10 }  # Extended length?

    my buf8 $path-attribute = buf8.new();
    $path-attribute.append( $flag );
    $path-attribute.append( 15 );       # Attribute Code

    my $len = $withdrawn.bytes + 3;

    if $withdrawn.bytes > 255 {
        $path-attribute.append( nuint16-buf8( $len ) );
    } else {
        $path-attribute.append( $len );
    }

    $path-attribute.append( 0, 2, 1 ); # IPv6 (0,2), Unicast (1)
    $path-attribute.append( $withdrawn );
    
    if $path-attribute.bytes > (65535-18) { die("Message would be too long") }

    return self.bless( :raw( $path-attribute ), :$asn32 );
};

method afi(-->Str:D) {
    ### XXX Should do length check
    return afi-name( nuint16(self.data[0], self.data[1]) );
}

method safi(-->Str:D) {
    ### XXX Should do length check
    return safi-name( self.data[2] );
}

method withdrawn(-->Array[Str:D]) {
    my Str:D @return;
    if self.data.bytes < 4 { return @return }

    my $buf = buf8.new: self.data.subbuf( 3 );

    # We go different ways based on AFI - this might make sense to
    # subclass. XXX
    # We also don't handle IPv4 in MP-Unreachables because, in theory, nobody
    # does that.  I'll probably be proven wrong.
    if self.afi eq 'IPv6' and self.safi eq 'unicast' {
        @return = Net::BGP::CIDR.packed-to-array($buf, 6).map( { $^a.Str } );
    } else {
        @return.push: $buf».fmt("%02x").join;
    }
    return @return;
}

method withdrawn-cidrs(-->Array[Net::BGP::CIDR:D]) {
    my Net::BGP::CIDR:D @return;
    if self.data.bytes < 4 { return @return }

    my $buf = buf8.new: self.data.subbuf( 3 );

    if self.afi eq 'IPv6' and self.safi eq 'unicast' {
        @return = Net::BGP::CIDR.packed-to-array($buf, 6);
    } else {
        # Do nothing here;
    }
    return @return;
}

method Str(-->Str:D) {
    "MP-Unreachable={ self.afi }/{self.safi } {self.withdrawn.join(" ")}";
}

# Register path-attribute
INIT { Net::BGP::Path-Attribute.register(Net::BGP::Path-Attribute::MP-Unreachable) }

=begin pod

=head1 NAME

Net::BGP::Message::Path-Attribute::MP-Unreachable - BGP MP-Unreachable Path-Attribute Object

=head1 SYNOPSIS

  use Net::BGP::Path-Attribute::MP-Unreachable;

  my $cap = Net::BGP::Path-Attribute::MP-Unreachable.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Path-Attribute::MP-Unreachable.from-hash(
    {
        address-family => 'ipv6',
        next-hop       => '2001:db8::1',
        withdrawn      => ( '2001:db8::/32' )
    }
  );

=head1 DESCRIPTION

BGP MP-Unreachable Path-Attribute Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  Thakes a hash with keys for
C<address-family> (currently only C<ipv6> is recognized), C<next-hop>, and
C<unreachable> (a list of IPv6 addresses).

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

=head2 afi

The address family (in string form) represented by this attribute.

=head2 safi

The supplimental address family (in string form).

=head2 withdrawn

An array of withdrawn elements, in string format.

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
