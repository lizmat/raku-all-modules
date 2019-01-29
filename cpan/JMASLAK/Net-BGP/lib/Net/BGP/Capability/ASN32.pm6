use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Capability;
use Net::BGP::Conversions;

use StrictClass;
unit class Net::BGP::Capability::ASN32:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Capability
    does StrictClass;

# Generic Types
method implemented-capability-code(-->Int) { 65 }
method implemented-capability-name(-->Str) { "ASN32" }

method capability-name(-->Str:D) { "ASN32" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes == 6) {
    if $raw[0] ≠ 65 { die("Can only build a ASN32 capability"); }
    if $raw[1] ≠  4 { die("Bad capability length"); }

    my $obj = self.bless(:$raw);
    return $obj;
};

method from-hash(%params is copy)  {
    my @REQUIRED = «asn»;

    if %params<capability-code>:exists {
        if %params<capability-code> ≠ 65 {
            die "Can only create a ASN32 capability";
        }
        %params<capability-code>:delete;
    }

    if %params<capability-name>:exists {
        if %params<capability-name> ne "ASN32" {
            die "Can only create a ASN32 capability";
        }
        %params<capability-name>:delete;
    }

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    my buf8 $capability = buf8.new();
    $capability.append( 65 );  # Code
    $capability.append( 4 );   # Length
    $capability.append( nuint32-buf8(%params<asn>) );

    return self.bless(:raw( $capability ));
};

method asn(-->Int:D) {
    return nuint32($.raw[2..5]);
}

method Str(-->Str:D) {
    "ASN32=" ~ self.asn;
}

# Register capability
INIT { Net::BGP::Capability.register(Net::BGP::Capability::ASN32) }

=begin pod

=head1 NAME

Net::BGP::Message::Capability::ASN32 - BGP Four Octet ASN Capability Object

=head1 SYNOPSIS

  use Net::BGP::Capability::ASN32;

  my $cap = Net::BGP::Capability::ASN32.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Capability::ASN32.from-hash( %{ asn => 65550 } );

=head1 DESCRIPTION

BGP Four Octet ASN Capability Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  This parent class looks only for
the key of C<capability-code> and C<cvalue>.  Capability code should represent
the desired capability code.  Value should be a C<buf8> containing the payload
data (C<value> in RFC standards).

=head1 Methods

=head2 asn

ASN present in the capability object.

=head2 capability-code

Capability code of the object.

=head2 capability-name

The capability name of the object.

=head2 raw

Returns the raw (wire format) data for this capability.

=head2 payload

The raw byte buffer (C<buf8>) corresponding to the RFC definition of C<value>.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
