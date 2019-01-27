use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Error::Bad-Parameter-Length;
use Net::BGP::Parameter;

use StrictClass;
unit class Net::BGP::Parameter::Generic:ver<0.0.8>:auth<cpan:JMASLAK>
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
    return "$.parameter-code";
}

method from-raw(buf8:D $raw) {
    # Validate length
    if $raw.bytes < 2 {
        die(Net::BGP::Error::Bad-Parameter-Length.new(:length($raw.bytes)));
    }
    if $raw.bytes < ($raw[1] + 2) {
        die(Net::BGP::Error::Bad-Parameter-Length.new(:length($raw[1])));
    }

    return self.bless( :data(buf8.new($raw)) );
};

method from-hash(%params)  {
    my @REQUIRED = «parameter-code parameter-value»;

    # Delete unnecessary option
    if %params<parameter-name>:exists {
        if %params<parameter-code>.Str ≠ %params<parameter-name> {
            die("Parameter type and code don't match");
        }
        %params<parameter-code> = %params<parameter-name>.Int;
        %params<parameter-name>:delete
    }

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper parameter options");
    }
    
    # Max length is 253, because 253 + one byte type + one byte len = 255
    if %params<parameter-value>.bytes > 253 { die("Parameter too long"); }

    my buf8 $parameter = buf8.new();
    $parameter.append( %params<parameter-code> );
    $parameter.append( %params<parameter-value>.bytes );
    $parameter.append( %params<parameter-value> );

    return self.bless(:data( buf8.new($parameter) ));
};

method raw() { return $.data; }

method parameter-length() {
    return $.data[1];
}

method parameter-value() {
    return $.data.subbuf(2, $.data[1]);
}

method Str(-->Str) {
    "Type={ self.parameter-code } Len={ self.parameter-length }";
}

# Register handler
Net::BGP::Parameter.register(Net::BGP::Parameter::Generic, Int, Str);

=begin pod

=head1 NAME

Net::BGP::Parameter::Generic - BGP Generic Parameter

=head1 SYNOPSIS

  # We create generic parameters using the parent class.

  use Net::BGP::Parameter;

  my $msg = Net::BGP::Parameter.from-raw( $raw );

=head1 DESCRIPTION

Generic (undefined) BGP parameter type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

This simply throws an exception, since the hash format of a generic parameter
is not designed.

=head1 Methods

=head2 parameter-name

Returns a string that describes what parameter type the command represents.

This is the string representation of C<parameter-code()>.

=head2 parameter-code

Contains an integer that corresponds to the parameter-name.

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
