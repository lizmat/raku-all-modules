use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

# Ensure capabilities are registered, even though we don't use them
# here.
use Net::BGP::Capability;
use Net::BGP::Capability::ASN32;
use Net::BGP::Capability::Generic;
use Net::BGP::Capability::MPBGP;
use Net::BGP::Capability::Route-Refresh;
use Net::BGP::Error::Bad-Parameter-Length;
use Net::BGP::Parameter;

use StrictClass;
unit class Net::BGP::Parameter::Capabilities:ver<0.0.9>:auth<cpan:JMASLAK>
    is Net::BGP::Parameter
    does StrictClass;

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

has buf8 $.data is rw;

method parameter-code() {
    return $.data[0];
}

method parameter-name() {
    return "Capabilities";
}

method from-raw(buf8:D $raw) {
    # Validate length
    if $raw.bytes < 2 {
        die(Net::BGP::Error::Bad-Parameter-Length.new(:length($raw.bytes)));
    }
    if $raw.bytes < ($raw[1] + 2) {
        die(Net::BGP::Error::Bad-Parameter-Length.new(:length($raw[1])));
    }
    if $raw[0] ≠ 2 { die("Can only build a Capabilities parameter") }

    # Validate the capabilities parse.
    
    return self.bless( :data(buf8.new($raw)) );
};

method from-hash(%params)  {
    my @REQUIRED = «capabilities»;

    # Delete unnecessary option
    if %params<parameter-name>:exists {
        if %params<parameter-name> ne 'Capabilities' {
            die("Parameter name and code don't match");
        }
        %params<parameter-name>:delete
    }
    if %params<parameter-code>:exists {
        if %params<parameter-code> ≠ 2 {
            die("Can only build a Capabilities parameter");
        }
        %params<parameter-code>:delete;
    }

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper parameter options: " ~ %params.keys.join(", ") );
    }

    # XXX Don't add capabilities if nothing in the capabilities!
    my $value = buf8.new;
    %params<capabilities> //= [];
    for |%params<capabilities> -> $cap-hash {
        $value.append: Net::BGP::Capability.from-hash( $cap-hash ).raw;
    }
    %params<parameter-value> =  $value;
    
    # Max length is 253, because 253 + one byte type + one byte len = 255
    if %params<parameter-value>.bytes > 253 { die("Parameter too long"); }

    my buf8 $parameter = buf8.new();
    $parameter.append( 2 );     # Capabilities Option
    $parameter.append( %params<parameter-value>.bytes );
    $parameter.append( %params<parameter-value> );

    my $obj = self.bless(:data( $parameter ));

    # Validate capabilities parse
    $obj.capabilities.sink;

    return $obj;
};

method raw() { return $.data; }

method parameter-length() {
    return $.data[1];
}

method parameter-value() {
    return $.data.subbuf(2, $.data[1]);
}

method capabilities( -->Array[Net::BGP::Capability:D] ) {
    my Net::BGP::Capability:D @capabilities;
    my $start = 2;
    while $start < $!data.bytes {
        my $cap-len = $!data[$start+1] + 2;

        if ($start + $cap-len) > $!data.bytes {
            die("Capability too long for option field");
        }

        my $cap-raw = $!data[ $start..($start + $cap-len - 1) ];
        @capabilities.push: Net::BGP::Capability.from-raw( buf8.new($cap-raw) );

        # Get next capability
        $start += $cap-len;
    }

    return @capabilities;
}

method Str(-->Str) {
    "CAP=[" ~ self.capabilities.map({ .Str }).join('; ') ~ "]";
}

# Register handler
Net::BGP::Parameter.register(Net::BGP::Parameter::Capabilities, 2, 'Capabilities');

=begin pod

=head1 NAME

Net::BGP::Parameter::Capabilities - BGP Capabilities Parameter

=head1 SYNOPSIS

  # We create capabilities parameters using the parent class.

  use Net::BGP::Parameter;

  my $msg = Net::BGP::Parameter.from-raw( $raw );

=head1 DESCRIPTION

Capabilities BGP parameter type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

Allows a Capabilities parameter to be built from a hash.  The hash should
contain only C<parameter-value>.

=head1 Methods

=head2 parameter-name

Returns a string that describes what parameter type the command represents,
which is always C<Capabilities>.

=head2 parameter-code

Contains an integer that corresponds to the C<parameter-name>, a value of C<2>.

=head2 parameter-length

Returns an integer that corresponds to the parameter value's length.

=head2 parameter-value

Returns a buffer that corresponds to the parameter value.

=head2 raw

Contains the raw (wire format) data for this parameter.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
