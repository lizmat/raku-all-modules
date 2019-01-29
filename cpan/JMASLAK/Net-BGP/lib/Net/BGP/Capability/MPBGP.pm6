use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::AFI  :ALL;
use Net::BGP::SAFI :ALL;
use Net::BGP::Capability;
use Net::BGP::Conversions;

use StrictClass;
unit class Net::BGP::Capability::MPBGP:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Capability
    does StrictClass;

# Generic Types
method implemented-capability-code(-->Int) { 1 }
method implemented-capability-name(-->Str) { "MPBGP" }

method capability-name(-->Str:D) { "MPBGP" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes == 6) {
    if $raw[0] ≠ 1 { die("Can only build a MPBGP capability"); }
    if $raw[1] ≠ 4 { die("Bad capability length"); }

    my $obj = self.bless(:$raw);
    return $obj;
};

method from-hash(%params is copy)  {
    my @REQUIRED = «afi safi reserved»;

    # Optional
    %params<reserved> //= 0;

    if %params<capability-code>:exists {
        if %params<capability-code> ≠ 1 {
            die "Can only create a MPBGP capability";
        }
        %params<capability-code>:delete;
    }

    if %params<capability-name>:exists {
        if %params<capability-name> ne "MPBGP" {
            die "Can only create a MPBGPcapability";
        }
        %params<capability-name>:delete;
    }

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    my buf8 $capability = buf8.new();
    $capability.append( 1 );  # Code
    $capability.append( 4 );  # Length
    $capability.append( nuint16-buf8(afi-code(~%params<afi>)) );
    $capability.append( %params<reserved> );
    $capability.append( safi-code(~%params<safi>) );

    return self.bless(:raw( $capability ));
};

method afi(-->Str:D) {
    return afi-name($.raw[2] * (2⁸) + $.raw[3]);
}

method safi(-->Str:D) {
    return safi-name($.raw[5]);
}

method reserved(-->Int:D) {
    return $.raw[4];
}

method Str(-->Str:D) {
    "MPBGP={ self.afi }/{ self.safi }";
}

# Register capability
INIT { Net::BGP::Capability.register(Net::BGP::Capability::MPBGP) }

=begin pod

=head1 NAME

Net::BGP::Message::Capability::MPBGP - BGP Four Octet MPBGP Capability Object

=head1 SYNOPSIS

  use Net::BGP::Capability::MPBGP;

  my $cap = Net::BGP::Capability::MPBGP.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Capability::MPBGP.from-hash( %{
        afi => 'ip', safi => 'unicast'
  } );

=head1 DESCRIPTION

BGP Multi-Protocol BGP Capability Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  This parent class looks only for
the key of C<capability-code> and C<cvalue>.  Capability code should represent
the desired capability code.  Value should be a C<buf8> containing the payload
data (C<value> in RFC standards).

=head1 Methods

=head2 afi

AFI name present in the capability object.

=head2 safi

SAFI name present in the capability object.

=head2 reserved

Reserved field present in the capability object.

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
