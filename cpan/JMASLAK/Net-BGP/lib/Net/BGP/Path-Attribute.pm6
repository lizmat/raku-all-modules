use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use StrictClass;
unit class Net::BGP::Path-Attribute:ver<0.1.0>:auth<cpan:JMASLAK>
    does StrictClass;

use Net::BGP::Conversions;

my %path-attribute-codes := Hash[Net::BGP::Path-Attribute:U,Int].new;
my %path-attribute-names := Hash[Net::BGP::Path-Attribute:U,Str].new;

has buf8:D $.raw   is required;
has Bool:D $.asn32 is required is rw;

# Generic Types
method implemented-path-attribute-code(-->Int)   { … }
method implemented-path-attribute-name(-->Str)   { … }
method path-attribute-code\           (-->Int:D) { $!raw[1] }
method path-attribute-name\           (-->Str:D) { ~$!raw[1] }

# Generic Methods
method flags\           (-->Int:D)  {   $!raw[0]              }
method optional\        (-->Bool:D) { ( $!raw[0] +& 0x80 ).so }
method transitive\      (-->Bool:D) { ( $!raw[0] +& 0x40 ).so }
method partial\         (-->Bool:D) { ( $!raw[0] +& 0x20 ).so }
method extended-length\ (-->Bool:D) { ( $!raw[0] +& 0x10 ).so }
method reserved-flags\  (-->Int:D)  {   $!raw[0] +& 0x0f      }

method data-length(-->Int:D) {
    if self.extended-length {
        return nuint16( $!raw.subbuf(2, 2) );
    } else {
        return $!raw[2];
    }
}

method data(-->buf8) {
    if self.extended-length {
        return $!raw.subbuf(4, self.data-length);
    } else {
        return $!raw.subbuf(3, self.data-length);
    }
}

method payload(-->buf8:D) {
    if $.raw[1] == 0 { return buf8.new }
    return $.raw[2..*];
}

method register( Net::BGP::Path-Attribute:U $class -->Nil) {
    %path-attribute-codes{ $class.implemented-path-attribute-code } = $class;
    %path-attribute-names{ $class.implemented-path-attribute-name } = $class;
}

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 2, Bool:D :$asn32) {
    if %path-attribute-codes{ $raw[1] }:exists {
        return %path-attribute-codes{ $raw[1] }.from-raw($raw, :$asn32);
    } else {
        return %path-attribute-codes{ Int }.from-raw($raw, :$asn32);
    }
}

method from-hash(%params is copy, Bool:D :$asn32)  {
    # Delete unnecessary options
    if %params<path-attribute-code>:exists and %params<path-attribute-name>:exists {
        if %path-attribute-codes{ %params<path-attribute-code> } ≠ %path-attribute-names{ %params<path-attribute-name> } {
            die("Path-Attribute code and path-attribute name do not match");
        }
        %params<path-attribute-name>:delete
    }

    if %params<path-attribute-name>:exists and %params<path-attribute-code>:!exists {
        %params<path-attribute-code> = %path-attribute-names{ %params<path-attribute-name> }.implemented-path-attribute-code;
        %params<path-attribute-name>:delete
    }

    if %params<path-attribute-code>:!exists { die("Must provide path-attribute code { %params.keys.join(" ") }") }

    if %path-attribute-codes{ %params<path-attribute-code> }:exists {
        return %path-attribute-codes{ %params<path-attribute-code> }.from-hash(%params, :$asn32);
    } else {
        return %path-attribute-codes{ Int }.from-hash(%params, :$asn32);
    }
}

method path-attributes(
    buf8:D $buf is copy,
    Bool:D :$asn32
    -->Array[Net::BGP::Path-Attribute:D]
) {
    my Net::BGP::Path-Attribute:D @result;

    @result = gather {
        while $buf.bytes {
            if $buf.bytes < 3 { die("path attribute too short ({ $buf.bytes })"); }
            if $buf[0] +& 0x10 {
                if $buf.bytes < 4 { die("path attribute too short ({ $buf.bytes })"); }

                my $len = nuint16($buf.subbuf(2, 2));
                if $buf.bytes < ($len + 4) {
                    die("path attribute too short ({$buf.bytes} < {$len+4})");
                }

                take Net::BGP::Path-Attribute.from-raw( $buf.subbuf(0, $len+4), :$asn32 );
                $buf = $buf.subbuf($len+4);
            } else {
                if $buf.bytes < ($buf[2]+3) {
                    die("path attribute too short ({$buf.bytes} < {$buf[2]+3})");
                }

                take Net::BGP::Path-Attribute.from-raw( $buf.subbuf(0, $buf[2]+3), :$asn32 );
                $buf = $buf.subbuf($buf[2]+3);
            }
        }
    }

    return @result;
}

=begin pod

=head1 NAME

Net::BGP::Message::Path-Attribute - BGP Path-Attribute Object

=head1 SYNOPSIS

  use Net::BGP::Path-Attribute;

  my $cap = Net::BGP::Path-Attribute.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Path-Attribute.from-hash(
        %{ path-attribute-name => 'ASN32', asn => '65550' }
  );

=head1 DESCRIPTION

BGP Path-Attribute Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  This parent class looks only for
the key of C<path-attribute-code> or C<path-attribute-name>.  If a name is specified,
it must be associated with a registered child class.  If both a name and a
code are specified, the name and code must both be associated with the same
child class.

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

=head2 path-attributes

Takes a buffer consisting of multiple packed path-attributes.  Returns an array
of Path-Attributes.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
