use ENIGMA::Machine::Plugboard;
use ENIGMA::Machine::Rotor;
use ENIGMA::Machine::Factory;
use ENIGMA::Machine::Error;
use ENIGMA::Machine::Keyfile;

unit class ENIGMA::Machine:ver<0.0.2> is export;

constant @KEYBOARD_CHARS := 'A'..'Z';

has @.rotors    of Rotor;
has $.reflector of Rotor;
has $.plugboard of Plugboard;

has Int $!rotor_count;

submethod TWEAK() {

    # Ensure that either 3 or 4 rotors has been provided
    unless @!rotors.elems (<) (3, 4).Set {
        X::Error.new(
            reason => 'Invalid number of rotors provided',
            source => +@!rotors,
            suggestion => 'Provide either 3 or 4 rotors',
        ).throw;
    }
    
    $!rotor_count = @!rotors.elems;
}

# Create a Machine object using settings from key sheet.
multi method from-key-sheet( ::?CLASS:U $machine:
        :$rotors            = 'I II III',
        :$ring-settings     = Nil,
        :$reflector-setting = 'B',
        :$plugboard-setting = '',
) {

    my @rotors;
    # verify format of rotor set (string, list or array of rotors' models)
    # and get rotors.
    given $rotors {
        when Str:D   { @rotors = $rotors.words };
        when Array:D { @rotors = $rotors       };
        when List:D  { @rotors = $rotors       };
    }
   
    # validate number of rotors.
    my $num_rotors = @rotors.elems;
    unless ($num_rotors).Set (<) (3, 4).Set {
        X::Error.new(
            reason => 'Invalid number of rotors provided',
            source => +@!rotors,
            suggestion => 'Provide either 3 or 4 rotors',
        ).throw;
    }

    my @ring_settings;
    if not $ring-settings {
        @ring_settings = [0 for ^$num_rotors];
    }
    elsif $ring-settings ~~ Array:D {
        # array must be in the range 1-26 if numeric and A-Z if alphabetic
        @ring_settings = flat $ring-settings;
    }
    elsif $ring-settings ~~ Str:D {
        # when provided, numbers must be between 1-26
        # when provided, numbers must be between A-Z
        # so 1 = A, 2 = B, ..., 26 = Z
        for $ring-settings.split(/\s+/) {
            when /<[A..Z]>/  { @ring_settings.push($_.uc.ord - 'A'.ord) };
            when /<digit>+/  { @ring_settings.push($_.Int - 1)          };
            default {
                X::Error.new(
                    reason => 'Invalid ring setting',
                    source => $ring-settings,
                    suggestion => 'Provide a valid ring setting',
                ).throw;
            }
        }
    }

    # ensure number of rotors match number of ring settings
    if $num_rotors != @ring_settings.elems {
        X::Error.new(
            reason => "# of rotors doesn't match # of ring settings",
            source => $ring-settings,
            suggestion => 'Provide the same # of rotors and ring settings',
        ).throw;
    }
  
    # assign ring setting to respective rotor and create list of rotor objects
    my @rotor_list = [ create-rotor(|$_) for (@rotors Z @ring_settings) ];

    # assemble the machine
    return $machine.bless(
        rotors    => @rotor_list,
        reflector => create-reflector($reflector-setting),
        plugboard => Plugboard.from-key-sheet($plugboard-setting),
    );
}

# Create a Machine object using a hash (instead of Pairs) of settings from key sheet.
multi method from-key-sheet( ::?CLASS:U $machine: %settings ) {
     return $machine.from-key-sheet(
        rotors            => %settings{'rotors'},
        ring-settings     => %settings{'ring-settings'},
        reflector-setting => %settings{'reflector-setting'},
        plugboard-setting => %settings{'plugboard-setting'},
    );
}

# Create a Machine object using settings from key file content.
method from-key-file( ::?CLASS:U: Str $file-text, $day = Nil ) {
    
    # get settings for the day
    my %settings = get-daily-settings($file-text, $day);

    return self.from-key-sheet(%settings);
}

# Take a string of letters (3 or 4) and set the display value for each rotor.
method set-display( Str $val where 3 <= *.chars <= 4, --> Nil ) {

    unless $val.chars == $!rotor_count {
        X::Error.new(
            reason     => 'Incorrect length for display value',
            source     => $val,
            suggestion => 'Provide a display value equal to the # of rotors',
        ).throw;
    }

   for @!rotors.kv -> $k, $rotor {
        $rotor.set-display($val.substr($k, 1));
    }

}

# Return a string representing the display the operator sees.
method get-display( --> Str ) { 
    
    # Get each rotor's display value and join them
    return (map { .get-display() }, @!rotors).join();
}

# Simulate a front panel key press.
method key-press( Str $key where *.chars == 1, --> Str ) {

    # ensure the character is a letter found 
    # in the original keyboard (only uppercase letters)
    unless $key (<) @KEYBOARD_CHARS {
        X::Error.new(
            reason     => 'Invalid key press',
            source     => $key,
            suggestion => 'Provide an uppercase letter',
        ).throw;
    }

    # simulate the mechanical action of the machine of stepping
    # rotor(s) after a key press.
    self!step_rotors();

    # simulate the electrical operations
    my Int $signal_num = $key.ord - 'A'.ord;
    my Int $lamp_num = self!electrical_signal($signal_num);

    # return transformed key
    return @KEYBOARD_CHARS[$lamp_num];
}

# Run text through the machine and simulate key press for each valid character.
method process-text( 
    Str $text, 
    $replace-char = Nil, # Must be an uppercase letter
    --> Str
) {

    my @result;
    for $text.comb -> $key-pressed {
        my $c = $key-pressed.uc;
        
        # replace character not in the A-Z set.
        unless $c (<) @KEYBOARD_CHARS {
            $c = $replace-char;
            next unless $c; # leave character as is if not replacement
                            # character is provided and skip its encoding/decoding
        }

        my $k = self.key-press($c);
        @result.push($k);
    }
    
    return @result.join('');
}

# Return rotor's rotation count as a hash.
method get-rotor-counts( --> Hash ) {

    my @r = $!rotor_count == 3 
        ?? <L M R>      # Left, Middle, Right
        !! <L ML MR R>; # Left, Middle Left, Middle Right, Right
    my @counts = ($_.rotations for @!rotors);
    
    return %(flat @r Z @counts);
}

# Get grid representation of encoded message.
method get-grid( 
    Str $text is copy,
    Int $b-length = 4,                          # length of blocks
    Str $replace-char where *.chars == 1 = 'X', # replacement character
    --> Str
) {
    
    my Str $grid = '';
    $text ~= ' ' until $text.chars %% $b-length;
    my $ciphertext = self.process-text($text, $replace-char);

    my $counter = 1;
    for (0, $b-length...$ciphertext.chars - $b-length) -> $idx {
        my $block = $ciphertext.substr($idx, $b-length);
        $grid ~= $counter %% $b-length
            ?? $block ~ "\n"
            !! $block ~ ' ';
        $counter++;
    }
    
    return $grid;
}


# PRIVATE METHODS

# Simulate the mechanical action of pressing a key.
method !step_rotors( --> Nil ) {

    #my ( $rotor1, $rotor2, $rotor3 ) = @!rotors.reverse;
    my ( $rotor1, $rotor2, $rotor3 ) = @!rotors.reverse;

    # decide which rotor can move

    # rotor 2 rotates when rotor 1 completes a full revolution
    my $rotate2 = $rotor1.notch-over-pawl() || $rotor2.notch-over-pawl();

=comment
This caused a small problem:
my $rotate2 = $rotor1.notch-over-pawl() or $rotor2.notch-over-pawl();
So beware of operator precedence. 'or' & 'and' operators have lower precedence
than '='. Go figures!

    # rotor 3 rotates when rotor 2 completes a full revolution.
    my $rotate3 = $rotor2.notch-over-pawl();

    # rightmost rotor always rotates when a key is pressed.
    $rotor1.rotate();

    $rotor2.rotate() if $rotate2;
    $rotor3.rotate() if $rotate3;
}

# Simulate running an electrical signal through the machine in order to
# perform an encryption or decryption operation.)
method !electrical_signal( Int $signal_num, --> Int ) {

    my $pos = $!plugboard.signal($signal_num).Int;

    for @!rotors.reverse -> $rotor {
        $pos = $rotor.signal-in($pos);
    }

    $pos = $!reflector.signal-in($pos);

    for @!rotors -> $rotor {
        $pos = $rotor.signal-out($pos);
    }

    return $!plugboard.signal($pos).Int;
}


=begin pod
=NAME ENIGMA::Machine

=SYNOPSIS

=begin code
use v6;
use ENIGMA::Machine;

# set up machine according to the daily key sheet:
my $machine =  Machine.from-key-sheet(
    rotors => 'I II III',
    ring-settings => '9 5 17',
    reflector-setting => 'B',
    plugboard-setting => 'DC OM GI HS RJ',
);

# set machine initial star position
$machine.set-display('WMD');

# decrypt the message key
my $msg-key = $machine.process-text('WHN');

# set machine to decoded message key
$machine.set-display($msg-key);

# decrypt the ciphertext
my $plaintext = $machine.process-text('YQCRSJSVICXZGCZ');

say $plaintext;
=end code

=DESCRIPTION

C<ENIGMA::Machine> is the top-level class for the Enigma machine simulation.

=begin item
The C<new> constructor

The following is a description of the plugboard characteristics that can be
specified through the new constructor:

=begin item
B<C<rotors>> - A list (or array) containing 3 or 4 (for the Kriegsmarine M4 version) 
C<Rotor> objects. The order of the list is important. The first rotor is
the left-most rotor, and the last rotor is the right-most (from the operator's
perspective sitting at the machine).
=end item

=begin item
B<C<reflector>> - A C<Rotor> object to represent the reflector (UKW).
=end item

=begin item
B<C<plugboard>> - A C<Plugboard> object to represent the state of the plugboard.
=end item

=end item 

=begin item
The C<from-key-sheet> constructor

Similar to the C<new> constructor, C<from-key-sheet> can be used to create
C<Machine> objects, albeit from data you might find in a key sheet:

=begin item
B<C<rotors>> - Either a list (or array) of strings naming the rotors from
left to right or a single string: e.g. ["I", "III", "IV"] or "I III IV"
=end item

=begin item
B<C<ring-settings>> - either a list/tuple of integers, a string, or C<Nil> to
represent the ring settings to be applied to the rotors in the rotors list.
The acceptable values are:
=item A list/tuple of integers with values between 1-26.
=item A string; either space separated letters or numbers, e.g. 'B U L' or '2 21 12'. 
=item C<Nil> means all ring settings are 0.
=end item

=begin item
B<C<reflector-setting>> - A string that names the reflector to use.
=end item

=begin item
B<C<plugboard-setting>> - a string of plugboard settings as you might find 
on a key sheet.

Example:
=item 'PO ML IU KJ NH YT GB VF RE DC'
=item '18/26 17/4 21/6 3/16 19/14 22/7 8/1 12/25 5/9 10/15'

A value of C<Nil> means no plugboard connections are made, which means a straight
mapping is being used.
=end item

=end item 

=begin item
The C<from-key-file> constructor

Just like the C<from-key-sheet> constructor, C<from-key-file> can be used to 
create C<Machine> objects, but from a file containing the daily setting(s).


=begin item
B<C<fp>> - A file-like object that contains daily key settings
=end item

=begin item
B<C<day>> - The line labeled with the day number (1-31) will be used for the
settings. If day is Nil, the day number will be determined from today's date.
=end item 

=end item


=head1 METHODS

=head2 CONSTRUCTORS

method B<C<from-key-sheet>>

=begin code
method from-key-sheet(
	:$rotors = "I II III", 
	:$ring-settings = Nil, 
	:$reflector-setting = "B", 
	:$plugboard-setting = "", 
) returns Machine
=end code

Creates a Machine object using settings from a key sheet.

method B<C<from-key-sheet>>

=begin code
method from-key-sheet( %settings ) returns Machine
=end code

Creates a Machine object using a hash (instead of Pairs) of settings from key sheet.

method B<C<from-key-file>>

=begin code
method from-key-file( Str $file-text, $day = Nil ) returns Machine
=end code

Creates a Machine object using settings from key file content.

=head2 OTHER METHODS

method B<C<set-display>>

=begin code
method set-display( Str $val )
=end code

Takes a string of letters and set the display value for each rotor.

method B<C<get-display>>

=begin code
method get-display() returns Str
=end code

Returns a string representing the operator display.

method B<C<key-press>>

=begin code
method key-press( Str $key )
=end code

Simulates a front panel key press.

method B<C<process-text>>

=begin code
method process-text( Str $text, $replace-char = Nil )
=end code

Runs text through the machine and simulates key press for each valid character.

method B<C<get-rotor-counts>>

=begin code
method get-rotor-counts()
=end code

Returns rotor's rotation count as a hash.

method B<C<get-grid>>

=begin code
method get-grid(
	Str $text is copy, 
	Int $b-length = 4, 
	Str $replace-char = "X", 
)
=end code

Gets grid representation of encoded message.

=head1 SEE ALSO

L<Machine::Rotor>, L<Machine::Plugboard>

=head1 REPOSITORY

L<https://gitlab.com/uzluisf/enigma>

=head1 AUTHOR

Luis F. Uceta <uzluisf AT protonmail.com>

=end pod
