unit module ENIGMA::Machine::Factory;
use ENIGMA::Machine::Data;
use ENIGMA::Machine::Rotor;
use ENIGMA::Machine::Error;

# Create rotor objects from the data
multi sub create-rotor( Str $model, Int $ring-setting = 0 ) is export {
    if %ROTORS{$model}:exists {
        my %data = %ROTORS{$model};
        return Rotor.new(
           model          => $model,
           wiring         => %data{'wiring'},
           ring-setting   => $ring-setting,
           turnover       => %data{'turnover'},
        );
    }

    X::Error.new(
        message => "Unknown rotor type",
        source  => $model,
    ).throw;

}

# Create custom rotor objects or create default ones manually
multi sub create-rotor( 
    Str :$wiring!, 
    Int :$ring-setting where 0..25 = 0, 
    Str :$turnover where 'A'..'Z'  = 'A',
    Str :$model                    = 'CUSTOM',
) is export {

    return Rotor.new(
        model        => $model,
        wiring       => $wiring,
        ring-setting => $ring-setting,
        turnover     => $turnover,
    );
}


# Create reflector objects from the data
multi sub create-reflector( Str $model ) is export {
    if %REFLECTORS{$model}:exists {
        return Rotor.new(
            model => $model,
            wiring => %REFLECTORS{$model},
        );
    }

    X::Error.new(
        message => "Unknown reflector type",
        source  => $model,
    ).throw;
}

# Create custom reflector objects or create default ones manually
multi sub create-reflector( 
    Str :$wiring!, 
    Str :$model  = 'CUSTOM',
) is export {

    return Rotor.new(
        model        => $model,
        wiring       => $wiring,
    );
}


=begin pod
=NAME ENIGMA::Machine::Factory

=SINOPSYS
=begin code
use v6;
use ENIGMA::Machine::Factory;

my $rotor = create-rotor('II');
my $reflector = create-reflector('B');
=end code

=DESCRIPTION

C<ENIGMA::Machine::Factory> stores two helper subroutines to create
rotor and reflector objects:

=begin item
B<C<create-rotor>>

This subroutine can be used to create rotor objects from the data available at
L<Data.pm6 | lib/ENIGMA/Machine/Data.pm6>. To do this, you must provide at least
a valid rotor's model as a positional argument. For example,
=begin code
my $standard-rotor = create-rotor('V');    # offset: 0
my $offset5-rotor = create-rotor('V', 5);  # offset: 5
=end code

C<offset5-rotor> is a type V rotor with an offset of 5.

Alternatively, you can create a custom rotor by providing at least the rotor's
wiring as a named argument. For example,
=begin code
my $standardish-rotor = create-rotor(
    wiring => 'VZBRGITYUPSDNHLXAWMJQOFECK',
    ring-setting => 5,
    turnover => 'Q',
    model => 'Type V',
);
=end code
is also a type V rotor with ring setting of 5 but created manually.
=end item

=begin item
B<C<create-reflector>>

This subroutine is similar to C<create-rotor>. To create a reflector object
using the data available in L<Data.pm6 | /lib/ENIGMA/Machine/Data.pm6>, 
call the subroutine with the the reflector's model:
=begin code
my $reflector = create-reflector('B');
=end code

Or create a custom reflector object like this:
=begin code 
my $custom-reflector = create-reflector(
    wiring => 'TAJVWCZFBEIMKOGNXPDLSQHURY', 
    model  => 'B-FLIPPED'
);
=end code
=end item
=end pod


