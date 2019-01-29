use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use StrictClass;
unit class Net::BGP::Capability:ver<0.1.0>:auth<cpan:JMASLAK> does StrictClass;

my %capability-codes := Hash[Net::BGP::Capability:U,Int].new;
my %capability-names := Hash[Net::BGP::Capability:U,Str].new;

has buf8:D $.raw is required;

# Generic Types
method implemented-capability-code(-->Int)   { … }
method implemented-capability-name(-->Str)   { … }
method capability-code\           (-->Int:D) { $!raw[0] }
method capability-name\           (-->Str:D) { $!raw[0] }
method capability-length\         (-->Int:D) { $!raw[1] }

method payload(-->buf8:D) {
    if $.raw[1] == 0 { return buf8.new }
    return $.raw[2..*];
}

method register( Net::BGP::Capability:U $class -->Nil) {
    %capability-codes{ $class.implemented-capability-code } = $class;
    %capability-names{ $class.implemented-capability-name } = $class;
}

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 2) {
    if %capability-codes{ $raw[0] }:exists {
        return %capability-codes{ $raw[0] }.from-raw($raw);
    } else {
        return %capability-codes{ Int }.from-raw($raw);
    }
};

method from-hash(%params is copy)  {
    # Delete unnecessary options
    if %params<capability-code>:exists and %params<capability-name>:exists {
        if %capability-codes{ %params<capability-code> } ≠ %capability-names{ %params<capability-name> } {
            die("Capability code and capability name do not match");
        }
        %params<capability-name>:delete
    }

    if %params<capability-name>:exists and %params<capability-code>:!exists {
        %params<capability-code> = %capability-names{ %params<capability-name> }.implemented-capability-code;
        %params<capability-name>:delete
    }

    if %params<capability-code>:!exists { die("Must provide capability code { %params.keys.join(" ") }") }

    if %capability-codes{ %params<capability-code> }:exists {
        return %capability-codes{ %params<capability-code> }.from-hash(%params);
    } else {
        return %capability-codes{ Int }.from-hash(%params);
    }
}

=begin pod

=head1 NAME

Net::BGP::Message::Capability - BGP Capability Object

=head1 SYNOPSIS

  use Net::BGP::Capability;

  my $cap = Net::BGP::Capability.from-raw( $raw );
  # or …
  my $cap = Net::BGP::Capability.from-hash(
        %{ capability-name => 'ASN32', asn => '65550' }
  );

=head1 DESCRIPTION

BGP Capability Object

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Constructs a new object for a given hash.  This parent class looks only for
the key of C<capability-code> or C<capability-name>.  If a name is specified,
it must be associated with a registered child class.  If both a name and a
code are specified, the name and code must both be associated with the same
child class.

=head1 Methods

=head2 capability-code

Cpaability code of the object.

=head2 capability-name

The capability name of the object.

=head2 payload

The raw byte buffer (C<buf8>) corresponding to the RFC definition of C<value>.

=head2 raw

Returns the raw (wire format) data for this capability.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
