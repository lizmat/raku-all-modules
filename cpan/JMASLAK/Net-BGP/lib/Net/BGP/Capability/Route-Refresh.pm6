use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Capability;

use StrictClass;
unit class Net::BGP::Capability::Route-Refresh:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Capability
    does StrictClass;

# Generic Types
method implemented-capability-code(-->Int) { 2 }
method implemented-capability-name(-->Str) { "Route-Refresh" }

method capability-name(-->Str:D) { "Route-Refresh" }

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes == 2) {
    if $raw[0] ≠ 2 { die("Can only build a Route-Refresh capability"); }
    if $raw[1] ≠ 0 { die("Bad capability length"); }

    my $obj = self.bless(:$raw);
    return $obj;
};

method from-hash(%params is copy)  {
    my @REQUIRED = «»;

    if %params<capability-code>:exists {
        if %params<capability-code> ≠ 2 {
            die "Can only create a route-refresh capability";
        }
        %params<capability-code>.delete;
    }

    if %params<capability-name>:exists {
        if %params<capability-name> ne "Route-Refresh" {
            die "Can only create a route-refresh capability";
        }
        %params<capability-name>.delete;
    }

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    my buf8 $capability = buf8.new();
    $capability.append( 2 );  # Code
    $capability.append( 0 );  # Length

    return self.bless(:raw( $capability ));
};

method Str(-->Str:D) {
    "Route-Refresh";
}

# Register capability
INIT { Net::BGP::Capability.register(Net::BGP::Capability::Route-Refresh) }

=begin pod

=head1 NAME

Net::BGP::Message::Capability::Route-Refresh - BGP Route-Refresh Capability Object

=head1 SYNOPSIS

  use Net::BGP::Capability::Route-Refresh;

  my $cap = Net::BGP::Capability::Route-Refresh.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Capability::Route-Refresh.from-hash( %{ } );

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
