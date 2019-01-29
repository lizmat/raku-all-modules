use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Path-Attribute;

use StrictClass;
unit class Net::BGP::Path-Attribute::Generic:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Path-Attribute
    does StrictClass;

use Net::BGP::Conversions;

# Generic Types
method implemented-path-attribute-code(-->Int) { Int }
method implemented-path-attribute-name(-->Str) { Str }

method path-attribute-name(-->Str:D) { "{ $.raw[1] }" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 3, Bool:D :$asn32) {
    if $raw[0] +& 0x10 {
        if ($raw.bytes - 4) ≠ nuint16($raw.subbuf(2,2)) {
            die("Invalid path-attribute payload length");
        }
    } else {
        if ($raw.bytes - 3) ≠ $raw[2] {
            die("Invalid path-attribute payload length");
        }
    }

    my $obj = self.bless(:$raw, :$asn32);
    return $obj;
};

method from-hash(%params is copy, :$asn32)  {
    my @REQUIRED = «path-attribute-code value optional transitive partial»;

    %params<optional>   //= False;
    %params<transitive> //= False;
    %params<partial>    //= False;

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    if %params<path-attribute-code> !~~ ^256 { die "Path-Attribute code is invalid" }

    if %params<value>.bytes > 65535 { die "Value is longer than 65535 bytes" }

    my $flag = 0;
    $flag += 0x80 if %params<optional>;
    $flag += 0x40 if %params<transitive>;
    $flag += 0x20 if %params<partial>;
    $flag += 0x10 if %params<value>.bytes > 255;

    my buf8 $path-attribute = buf8.new();
    $path-attribute.append( $flag );
    $path-attribute.append( %params<path-attribute-code> );

    if %params<value>.bytes > 255 {
        $path-attribute.append( nuint16-buf8(%params<value>.bytes) );
    } else {
        $path-attribute.append( %params<value>.bytes );
    }
    
    $path-attribute.append( %params<value> );

    return self.bless(:raw( $path-attribute ), :$asn32);
};

method Str(-->Str:D) {
    "Code=" ~ self.path-attribute-name ~ " Len=" ~ self.data-length;
}

# Register path-attribute
INIT { Net::BGP::Path-Attribute.register(Net::BGP::Path-Attribute::Generic) }

=begin pod

=head1 NAME

Net::BGP::Message::Path-Attribute::Generic - BGP Generic Path-Attribute Object

=head1 SYNOPSIS

  use Net::BGP::Path-Attribute::Generic;

  my $cap = Net::BGP::Path-Attribute::Generic.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Path-Attribute::Generic.from-hash(
    %{ path-attribute-name => 192, value => buf8.new(1,2,3,4) }
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

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
