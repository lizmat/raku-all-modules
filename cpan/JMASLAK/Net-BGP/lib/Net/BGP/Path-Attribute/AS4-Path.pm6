use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Path-Attribute;

use StrictClass;
unit class Net::BGP::Path-Attribute::AS4-Path:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Path-Attribute
    does StrictClass;

use Net::BGP::Conversions;
use Net::BGP::AS-List;

# AS4-Path Types
method implemented-path-attribute-code(-->Int) { 17 }
method implemented-path-attribute-name(-->Str) { "AS4-Path" }

method path-attribute-name(-->Str:D) { "AS4-Path" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 3, :$asn32) {
    if ! $raw[0] +& 0x80 { die("Optional flag must be set on AS4-Path attribute") }
    if ! $raw[0] +& 0x40 { die("Transitive flag must be set on AS4-Path attribute") }

    my $aslist;
    if $raw[0] +& 0x10 { # XXX Should check length field, but we skip it
        $aslist = Net::BGP::AS-List.as-lists( buf8.new($raw[4..*]), True );
    } else {
        $aslist = Net::BGP::AS-List.as-lists( buf8.new($raw[3..*]), True );
    }

    if $raw[1] ≠ 17 { die("Can only create a AS4-Path attribute") }

    @$aslist».check;     # Validate all are proper

    my $obj = self.bless(:$raw, :asn32);
    return $obj;
};

method from-hash(%params is copy, Bool:D :$asn32)  {
    my @REQUIRED = «as4-path»;

    # Remove path attributes
    if %params<path-attribute-code>:exists {
        if %params<path-attribute-code> ≠ 17 {
            die("Can only create an AS4-Path attribute");
        }
        %params<path-attribute-code>:delete;
    }
    if %params<path-attribute-name>:exists {
        if %params<path-attribute-name> ≠ 'AS4-Path' {
            die("Can only create an AS4-Path attribute");
        }
        %params<path-attribute-name>:delete;
    }

    my @aslists = Net::BGP::AS-List.from-str(%params<as4-path>, True);
    my $as4-path-buf = buf8.new;
    for @aslists -> $aslist { $as4-path-buf.append: $aslist.raw }

    # Check to make sure attributes are correct
    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    if $as4-path-buf.bytes > 65535 { die "Value is longer than 65535 bytes" }

    my $flag = 0x40;  # Transitive
    if $as4-path-buf.bytes > 255 { $flag += 0x10 }  # Extended length?

    my buf8 $path-attribute = buf8.new();
    $path-attribute.append( $flag );
    $path-attribute.append( 17 );

    if $as4-path-buf.bytes > 255 {
        $path-attribute.append( nuint16-buf8( $as4-path-buf.bytes ) );
    } else {
        $path-attribute.append( $as4-path-buf.bytes );
    }
    $path-attribute.append( $as4-path-buf );

    return self.bless( :raw( $path-attribute ), :asn32 );
};

method as-lists(-->Array[Net::BGP::AS-List:D]) {
    my Net::BGP::AS-List:D @return;

    if $.raw[0] +& 0x10 { # XXX Should check length field, but we skip it
        @return = Net::BGP::AS-List.as-lists( buf8.new($.raw[4..*]), True);
    } else {
        @return = Net::BGP::AS-List.as-lists( buf8.new($.raw[3..*]), True);
    }
}

# Using RFC4271 9.1.2.2.a semmantics
method path-length(-->Int:D) {
    return @(self.as-lists».path-length).sum;
}

method as4-path(-->Str:D) { (join " ", self.as-lists».Str) }

method Str(-->Str:D) { "AS4-Path=" ~ self.as4-path }

# Register path-attribute
INIT { Net::BGP::Path-Attribute.register(Net::BGP::Path-Attribute::AS4-Path) }

=begin pod

=head1 NAME

Net::BGP::Message::Path-Attribute::AS4-Path - BGP AS4-Path Path-Attribute Object

=head1 SYNOPSIS

  use Net::BGP::Path-Attribute::AS4-Path;

  my $cap = Net::BGP::Path-Attribute::AS4-Path.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Path-Attribute::AS4-Path.from-hash(
    !!! # NOT YET IMPLEMENTED
  );

=head1 DESCRIPTION

BGP Path-Attribute Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  This requires elements with keys of
C<path-attribute-code> and C<value>.  Path-Attribute code should represent the
desired path-attribute code.  Value should be a C<buf8> containing the payload
data (C<value> in RFC standards).

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

=head2 as4-path

Returns a string representation of the AS path.

=head2 path-length

Returns the length of the AS path, as calculated according to RFC4271 section
9.1.1.2.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
