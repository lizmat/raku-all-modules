use ENIGMA::Machine::Error;
unit class ENIGMA::Machine::Rotor is export;

# Each letter in the rotor's wiring must appear exactly once.
# This variable helps to enforce this requirement.
my constant $WIRING_FREQ_SET = ('A'..'Z').Set;

# Attributes used to create a Rotor object through 
# the new constructor.
has Str $.model        = 'NO DEFINED';
has Str $.wiring;
has Int $.ring-setting = 0;
has $.turnover         = Nil;


has $.rotations   = 0;
has $!pos         = 0;
has $!display_val;
has @!entry_map;
has @!exit_map;
has %!display_map;
has %!pos_map;
has $!step_set;


submethod TWEAK() {
    # Ideally, the wiring is supplied as uppercase letters.
    $!wiring .= uc;

    # Check the wiring string has the right length
    unless $!wiring.chars == 26 {
        X::Error.new(
            reason => 'Invalid wiring length',
            source => $!wiring.chars,
            suggestion => 'Provide a wiring with length 26',
       ).throw;
    }

    # Check the wiring format; it must contain characters A-Z only
    if $!wiring.match(/<-[A..Z]>+/) {
        X::Error.new(
            reason => 'Wiring with invalid characters',
            source => $!wiring.match(/<-[A..Z]>+/).Str,
            suggestion => 'Provide wiring with only uppercase letters',
       ).throw;
    }

    # Check every letter in the wiring appears exactly once.
    # WIRING_FREQ_SET must be a subset of or equal to wiring.
    # This doesn't happen if wiring has the wrong frequency.
    unless $WIRING_FREQ_SET (<=) ($!wiring.comb).Set {
        X::Error.new(
            reason => 'Invalid wiring frequency',
            source => ($!wiring.comb.Bag (-) $WIRING_FREQ_SET).keys.sort.Str,
            suggestion => 'Provide wiring where letter exactly once',
       ).throw;
    }

    # Check ring setting is valid. A valid ring setting
    # is an integer between 0 and 25 inclusive.
    unless 0 <= $!ring-setting <= 25 {
        X::Error.new(
            reason => "Invalid ring setting",
            source => $!ring-setting,
            suggestion => 'Provide an integer 0-25 (inclusive)',
       ).throw;
    }

    # Create two lists to describe the internal wiring. 
    # Two lists are used to do fast lookup from both entry 
    # (from the right) and exit (from the left). 
    @!entry_map = flat [ord($_) - ord('A') for $!wiring.comb];

    for @!entry_map.kv -> $k, $v { @!exit_map[$v] = $k }

    # Build a map of display values to positions relative to ring setting
    # e.g., %('A' => 1, B => 2, ... )
    %!display_map = map {
        chr( 'A'.ord + $_ ) => ($_ - $!ring-setting) % 26
    }, ^26;
    
    # Build a reversed map of positions to display values 
    # e.g., %(1 => 'A', ... )
    %!pos_map = %(flat %!display_map.values Z %!display_map.keys);

    # Build a step set; this is a set of positions where our notches are
    # in place to allow the pawls to push the left rotors.
    if $!turnover {
        my @steps;
        for $!turnover.comb -> $step {
            with %!display_map{$step} {
                @steps.push($step);
            }
            else {
                X::Error.new(
                    message => 'Wrong turnover',
                    source => $step,
                    suggestion => 'Provide uppercase letter(s)', 
                ).throw;
            }
        }

        $!step_set = set @steps;
    }

    # Initialize display value (default for all rotors)
    self.set-display('A');
}


# Returns hash of value-position pairs.
method get-display-map( --> Hash ) { %!display_map }

# Returns hash of position-value pairs.
method get-pos-map( --> Hash ) { %!pos_map }

# spins rotor by given value. Value must be in the range A-Z.
method set-display(Str $val, --> Nil) {
    my $s = $val.uc;

    unless %!display_map{$s}:exists {
        X::Error.new(
            reason => 'Bad display value',
            source => $s,
            suggestion => "Please enter a letter (e.g. 'A' or 'a')",
       ).throw;
    }
    $!pos = %!display_map{$s};
    $!display_val = $s;
    $!rotations = 0;

}

# get letter (A-Z) currently being displayed.
method get-display( --> Str ) { $!display_val }

# simulate a signal entering the rotor from the right (a key press in the keyboard)
# at a given pin position n.
method signal-in( Int $n where 0 <= $n <= 25, --> Int ) {
    
    # determine what eletrical pin contact we have 
    # at that position due to rotation
    my $pin = ($n + $!pos) % 26;

    # run it through the internal wiring and out to
    # the flat electrical contact
    my $contact = @!entry_map[$pin];

    # turn back into a position due to rotation
    return ($contact - $!pos) % 26;
}

# simulate a signal entering the rotor from the left (signal coming back from
# the reflector) at a given pin position n.
method signal-out( Int $n, --> Int ) {

    # determine what contact we have at that position due to rotation
    my $contact = ($n + $!pos) % 26;

    # determine what contact we have at that position due to rotation
    my $pin = @!exit_map[$contact];
    
    # turn back into a position due to rotation
    return ($pin - $!pos) % 26;
}

# check if rotor has a notch in the stepping position.
method notch-over-pawl( --> Bool ) {
    return $!display_val.Set() (<=) $!step_set;
}


# Rotate the rotor forward due to mechanical stepping action.
method rotate ( --> Nil ) {
    $!pos = ($!pos + 1) % 26;
    $!display_val = %!pos_map{$!pos};
    $!rotations += 1;
}

# get rotor's number of rotations.
method get-rotor-counts( --> Int ) { $!rotations }




=begin pod
=head1 NAME 
ENIGMA::Machine::Rotor

=head1 PREAMBLE

A rotor has 26 circularly arranged pins on the right (entry) side and 26
contacts on the left side (exit). Each pin is connected to a single contact by
internal wiring, thus establishing a substitution cipher. We represent this
wiring by establishing a mapping from a pin to a contact (and vice versa for
the return path). Internally we number the pins and contacts from 0-25 in a
clockwise manner with 0 being the "top".

An alphabetic or numeric ring is fastened to the rotor by the operator. The
labels of this ring are displayed to the operator through a small window on
the top panel. The ring can be fixed to the rotor in one of 26 different
positions; this is called the ring setting (Ringstellung). We will number
the ring settings from 0-25 where 0 means no offset (e.g. the letter "A" is
mapped to pin 0 on an alphabetic ring). A ring setting of 1 means the letter
"B" is mapped to pin 0.

Each rotor can be in one of 26 positions on the spindle, with position 0
where pin/contact 0 is being indicated in the operator window. The rotor
rotates towards the operator by mechanical means during normal operation as
keys are being pressed during data entry. Position 1 is thus defined to be
one step from position 0. Likewise, position 25 is the last position before
another step returns it to position 0, completing 1 trip around the spindle.

Finally, a rotor has a "stepping" or "turnover" parameter. Physically this
is implemented by putting a notch on the alphabet ring and it controls when
the rotor will "kick" the rotor to its left, causing the neighbor rotor to
rotate. Most rotors had one notch, but some Kriegsmarine rotors had 2
notches and thus rotated twice as fast.

Note that due to the system of ratchets and pawls, the middle rotor (in a 3
rotor Enigma) can "double-step". The middle rotor will advance on the next
step of the first rotor a second time in a row, if the middle rotor is in
its own turnover position.

Note that we allow the stepping parameter to be Nil. This indicates the
rotor does not rotate. This allows us to model the entry wheel and
reflectors as stationary rotors.


=head1 SYNOPSIS
=begin code
use v6;
use ENIGMA::Machine:Rotor;

# Creating a rotor object
my $r = Rotor.new(
    model        => 'I',
    wiring       => 'EKMFLGDQVZNTOWYHXUSPAIBRCJ',
    ring-setting => 0,
    turnover     => 'Q',
);
=end code

Rotor C<$r> represents the type I rotor (for Enigma I, M3, and M4) 
with no offset.

=head1 DESCRIPTION
=para
The C<ENIGMA::Machine::Rotor> class represents the Enigma Machine rotors (Walzen). 

The following is a description of the rotor characteristics that can be specified
through the C<new> constructor:

=begin item
B<C<model>> - The rotor's model. 

For example, 'I', 'II', 'Beta', 'Gamma', etc. Giving that the rotor's wiring
must be provided when setting up a rotor through the C<new> constructor, the
rotor's model is of little importance so any name would do.
=end item

=begin item
B<C<wiring>> - A string of 26 alphabetic characters that represents the internal wiring
of the rotor. 

For example, for the Wehrmacht Enigma type I rotor the mapping is 
"EKMFLGDQVZNTOWYHXUSPAIBRCJ".
=end item

=begin item
B<C<ring-setting>> - A number between 0 and 25 (inclusive) that indicates the
position of the rotor wiring relative to the alphabet ring. 

Changing the position of the ring will change the position of the notch and 
the ring alphabet, relative to the internal wiring. This was done on each
rotor by locking the alphabet ring with a springloaded pin (Wehrmacht) or 
two springloaded arcs (Kriegmarine) in the zero mark.

A value of 0 means there is no offset. This means the letter "A" in the 
ring alphabet is clip to a L<zero mark|http://www.cryptomuseum.com/crypto/enigma/i/img/300002/056/full.jpg>
in the rotor.

As noted before, the wiring for the type I rotor (I, M3 and M4) is 
"EKMFLGDQVZNTOWYHXUSPAIBRCJ". With aring setting of 0,
the rotor's substitution looks like this:

=begin code
ABCDEFGHIJKLMNOPQRSTUVWXYZ # alphabet ring
EKMFLGDQVZNTOWYHXUSPAIBRCJ # wiring
=end code

With a ring setting of 1, the substitution looks like this: 

=begin code
ZABCDEFGHIJKLMNOPQRSTUVWXY # alphabet ring
EKMFLGDQVZNTOWYHXUSPAIBRCJ # wiring
=end code

=end item

=begin item
B<C<turnover>> - This is the stepping or turnover parameter.

For example, the turnover in the type I rotor is 'Q'. This indicates
that when the rotor transitions from 'Q' to 'R' (visible to the operator 
through the window/lid), the notch in the letter ring (located in the 
letter "Y" in this case) will allow the pawl to engage and 
push the ratchet in the rotor to its left which in turn rotates it.

In the type II rotor (for Enigma I, M3 and M4), the turnover happens when
the rotor transitions from 'E' to 'R', the notch (in the letter 'M') will
engage with the pawl which will keep the rotor to its left.

Some rotors have two notches, which translates into two turnovers. For
example, the type VIII rotor (for Enigma I, M3 and M4), has two notches 'H' 
and 'U' and turnovers happens when the rotor transitions from 'Z' to 'A' and 
'M' to 'N' respectively.
=end item

=head1 METHODS

method B<C<get-display-map>>

=begin code
method get-display-map() returns Hash
=end code

Returns a hash of value-position pairs for rotor's current state.

method B<C<get-pos-map>>

=begin code
method get-pos-map() returns Hash
=end code

Returns a hash of position-value pairs for rotor's current state.

method B<C<set-display>>

=begin code
method set-display( Str $val )
=end code

Spins the rotor such that the string val appears in the operator window 
which sets the internal position of the rotor on the axle and thus rotates
the pins and contacts accordingly. For instance, a value of 'A' puts the
rotor in position 0, assuming an internal ring setting of 0. The parameter
val must be a string in the range 'A' - 'Z'. Setting the display resets 
the internal rotation counter to 0.

method B<C<get-display>>

=begin code
method get-display() returns Str
=end code

Returns value (a letter) currently being displayed in the operator window.

method B<C<signal-in>>

=begin code
method signal-in( Int $n ) returns Int
=end code

Simulates a signal entering the rotor from the right at a given pin position n.
 
method B<C<signal-out>>

=begin code
method signal-out( Int $n ) returns Int
=end code

Simulates a signal entering the rotor from the left at a given pin position n.

method B<C<notch-over-pawl>>

=begin code
method notch-over-pawl() returns Bool
=end code

Returns True if invocant rotor has a notch in the stepping position.
Otherwise, returns False.

method B<C<rotate>>

=begin code
method rotate() returns Nil
=end code

Rotates the rotor forward due to the mechanical stepping action.
 
method B<C<get-rotor-counts>>

=begin code
method get-rotor-counts() returns Int
=end code

Gets the number of rotations a rotor has performed. The number of rotations for
a specific rotor is set to 0 when the rotor's display is set.


=end pod
