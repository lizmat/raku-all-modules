use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Path-Attribute;

use StrictClass;
unit class Net::BGP::Path-Attribute::Origin:ver<0.1.1>:auth<cpan:JMASLAK>
    is Net::BGP::Path-Attribute
    does StrictClass;

use Net::BGP::Conversions;

# Origin Types
method implemented-path-attribute-code(-->Int) { 1 }
method implemented-path-attribute-name(-->Str) { "Origin" }

method path-attribute-name(-->Str:D) { "Origin" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes == 4, Bool:D :$asn32) {
    if   $raw[0] +& 0x80 { die("Optional flag not valid on Origin attribute") }
    if ! $raw[0] +& 0x40 { die("Transitive flag must be set on Origin attribute") }
    if   $raw[0] +& 0x20 { die("Partial flag not valid on Origin attribute") }
    if   $raw[0] +& 0x10 { die("Extended length flag not valid on Origin attribute") }

    if   $raw[1] ≠ 1     { die("Can only create an Origin attribute") }

    if ($raw.bytes - 3) ≠ $raw[2] { die("Invalid path-attribute payload length") }
    if $raw[2] ≠ 1              { die("Invalid path-attribute payload length") }

    if   $raw[3] !~~ ^3  { die("Invalid origin in Origin attribute ({$raw[3]})") }

    my $obj = self.bless(:$raw, :$asn32);
    return $obj;
};

method from-hash(%params is copy, Bool:D :$asn32)  {
    my @REQUIRED = «origin»;

    # Remove path attributes
    if %params<path-attribute-code>:exists {
        if %params<path-attribute-code> ≠ 1 {
            die("Can only create an Origin attribute");
        }
        %params<path-attribute-code>:delete;
    }
    if %params<path-attribute-name>:exists {
        if %params<path-attribute-name> ≠ 'Origin' {
            die("Can only create an Origin attribute");
        }
        %params<path-attribute-name>:delete;
    }

    # Check to make sure attributes are correct
    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    my $value;
    given %params<origin>.fc {
        when 'i' { $value = 0 }
        when 'e' { $value = 1 }
        when '?' { $value = 2 }
        default  { die("Unknown origin value") }
    }

    my $flag = 0x40;  # Transitive

    my buf8 $path-attribute = buf8.new();
    $path-attribute.append( $flag );
    $path-attribute.append( 1 );        # Origin
    $path-attribute.append( 1 );        # Length
    $path-attribute.append( $value );

    return self.bless(:raw( $path-attribute ), :$asn32);
};

method origin(-->Str:D) {
    given self.raw[3] {
        when 0  { return 'i' }
        when 1  { return 'e' }
        when 2  { return '?' }
        default { die("Invalid origin value") }
    }
}

method Str(-->Str:D) { "Origin=" ~ self.origin }

# Register path-attribute
INIT { Net::BGP::Path-Attribute.register(Net::BGP::Path-Attribute::Origin) }

=begin pod

=head1 NAME

Net::BGP::Message::Path-Attribute::Origin - BGP Origin Path-Attribute Object

=head1 SYNOPSIS

  use Net::BGP::Path-Attribute::Origin;

  my $cap = Net::BGP::Path-Attribute::Origin.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Path-Attribute::Origin.from-hash(
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

=head2 origin

Returns C<'i'>, C<'e'>, or C<'?'> based on origin code.

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
