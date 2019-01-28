use v6;

#
# Copyright (C) 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use StrictClass;
unit class Net::BGP::Parameter:ver<0.0.9>:auth<cpan:JMASLAK> does StrictClass;

my %registrations;
my %parameter-codes;

# Parameter type Nil = handle all unhandled parameters
method register(Net::BGP::Parameter $class, Int $parameter-code, Str $parameter-name) {
    if defined $parameter-code {
        %registrations{ $parameter-code } = $class;
        %parameter-codes{ $parameter-name } = $parameter-code;
    } else {
        %registrations<default> = $class;
    }
}

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method raw() {
    die("Not implemented for parent class");
}

method from-raw(buf8:D $raw) {
    if %registrations{ $raw[0] }:exists {
        return %registrations{ $raw[0] }.from-raw($raw);
    } else {
        return %registrations<default>.from-raw($raw);
    }
};

method from-hash(%params is copy)  {
    if %params<parameter-name>:!exists and %params<parameter-code>:!exists {
        die "Could not determine parameter type";
    }
        
    # Normalize parameter-name
    if %params<parameter-name>:exists and %params<parameter-name> ~~ m/^ <[0..9]>+ $/ {
        if %params<parameter-code>:exists and %params<parameter-code> ≠ %params<parameter-name> {
            die("Parameter type and code don't agree");
        } else {
            %params<parameter-code> = Int(%params<parameter-name>);
            %params<parameter-name>:delete;
        }
    }

    # Fill in parameter type if needed
    if %params<parameter-code>:!exists {
        if %parameter-codes{ %params<parameter-name> }:!exists {
            die("Unknown parameter code: %params<parameter-name>");
        }
        %params<parameter-code> = %parameter-codes{ %params<parameter-name> };
    }

    # Make sure we have agreement 
    if %params<parameter-name>:exists and %params<parameter-code>:exists {
        if %parameter-codes{ %params<parameter-name> } ne %params<parameter-code> {
            die("Parameter code and type don't agree");
        }
    }

    %params<parameter-name>:delete; # We don't use this in children.

    if %registrations{ %params<parameter-code> }:exists {
        return %registrations{ %params<parameter-code> }.from-hash( %params );
    } else {
        return %registrations<default>.from-hash( %params );
    }
};

method parameter-name() {
    die("Not implemented for parent class");
}

method parameter-code() {
    die("Not implemented for parent class");
}

method parameter-length() {
    die("Not implemented for parent class");
}

method parameter-value() {
    die("Not implemented for parent class");
}

=begin pod

=head1 NAME

Net::BGP::Parameter - BGP Parameter Parent Class

=head1 SYNOPSIS

  use Net::BGP::Parameter;

  my $msg = Net::BGP::Parameter.from-raw( $raw );

=head1 DESCRIPTION

Parent class for parameters.

=head1 Constructors

=head2 from-raw

Constructs a new object (likely in a subclass) for a given raw buffer.

=head2 from-hash

Constructs a new object (likely in a subclass) for a given hash buffer.  This
module uses the C<parameter-code> or C<parameter-name> key of the hash to determine
which type of parameter should be returned.

=head1 Methods

=head2 parameter-code

Contains an integer that corresponds to the parameter-name.

=head2 parameter-name

Returns a string that describes what parameter type the command represents.

Returns no codes are understood.

=head2 parameter-length

Returns an integer that corresponds to the parameter value's length.

=head2 parameter-value

Returns an integer that corresponds to the parameter value.

=head2 raw

Contains the raw parameter (not including the BGP header).

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
