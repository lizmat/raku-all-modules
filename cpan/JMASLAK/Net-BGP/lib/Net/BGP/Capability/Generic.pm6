use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Capability;

use StrictClass;
unit class Net::BGP::Capability::Generic:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Capability
    does StrictClass;

# Generic Types
method implemented-capability-code(-->Int) { Int }
method implemented-capability-name(-->Str) { Str }

method capability-name(-->Str:D) { "{ $.raw[0] }" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 2) {
    if ($raw.bytes - 2) ≠ $raw[1] { die("Invalid capability payload length"); }

    my $obj = self.bless(:$raw);
    return $obj;
};

method from-hash(%params is copy)  {
    my @REQUIRED = «capability-code value»;

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    if %params<capability-code> !~~ ^256 { die "Capability code is invalid" }

    # Yes, it's ^254, not ^256, because the maximum parameter size is
    # 255 bytes - so 253 bytes max (^254) plus the octets
    # representing the capability's code point and the capability's
    # length bring us to 253 + 2 = 255.
    if %params<value>.bytes !~~ ^254 { die "Value is longer than 255 bytes" }

    my buf8 $capability = buf8.new();
    $capability.append( %params<capability-code> );
    $capability.append( %params<value>.bytes );
    $capability.append( %params<value> );

    return self.bless(:raw( $capability ));
};

method Str(-->Str:D) {
    "Code=" ~ self.capability-name ~ " Len=" ~ self.capability-length;
}

# Register capability
INIT { Net::BGP::Capability.register(Net::BGP::Capability::Generic) }

=begin pod

=head1 NAME

Net::BGP::Message::Capability::Generic - BGP Generic Capability Object

=head1 SYNOPSIS

  use Net::BGP::Capability::Generic;

  my $cap = Net::BGP::Capability::Generic.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Capability::Generic.from-hash(
    %{ capability-name => 'ASN32', asn => '65550' }
  );

=head1 DESCRIPTION

BGP Capability Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  This parent class looks only for
the key of C<capability-code> and C<cvalue>.  Capability code should represent
the desired capability code.  Value should be a C<buf8> containing the payload
data (C<value> in RFC standards).

=head1 Methods

=head2 capability-code

Cpaability code of the object.

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
