use ENIGMA::Machine::PlugGrammar;
use ENIGMA::Machine::Error;

unit class ENIGMA::Machine::Plugboard is export;

# Number of cables supplied with machine. It was possible to use
# 13 cables but only 10 were historically used.
my Int $MAX-PAIR := 10;

# Set of unique pairs. Exclude pairs with same element and duplicates.
# ((26)(26) - 26 ) / 2 = 325
my $CONNECTIONS := (
    (0..25 X 0..25).duckmap(*.Set).grep: { $_ > 1 }
).Set;


# Attributes used for object construction
has $.wiring_str;
has @.wiring_pairs;

has @!wiring_map = 0..25;

# Create plugboard object from list of 2-tuples of integers
method new( :@setting ) {
 
    # Convert list of 2-tuples to the Kriegsmarine style
    my Str $connections = (
        map { join('/', $^a, $^b,) }, @setting.Str.comb(/\d+/)
    ).join(' ');

    # If setting is not empty or undefined
    if @setting {
        my $match = ZB-Syntax.parse(
            $connections, :actions(PLUGB-actions.new())
        );

        # Throw error if not match
        unless $match {
            X::Error.new(
                reason     => 'Invalid list of 2-tuples',
                source     => @setting.Str,
                suggestion => 'Provide list of 2-tuples with integers (0-25)',
            ).throw;
        }
    }

    return self.bless(
        wiring_pairs => @setting,
        wiring_str   => $connections,
    );
}

# Takes alphabetical or numerical pairs and returns Plugboard object.
method from-key-sheet( ::?CLASS:U $pb: Str $setting = '' ) {

    # parse the setting and get match object
    my $match = HK-Syntax.parse(
        $setting, :actions(PLUGB-actions.new())
    );

    # if there is no match
    unless $match {
        X::Error.new(
            reason => 'Invalid connections',
            source => $setting,
            suggestion => 'Provide connections in either Heer/Luftwaffe or Kriegsmarine style',
        ).throw;
    }

    my @connections = $match.made with $match;

    # determine if either Heer/Luftwaffe or Kriegsmarine is being used.
    given @connections[0][0].WHAT {
        # Heer/Luftwaffe style
        when Str { @connections = @connections.deepmap(*.ord - 'A'.ord) }
        
        # Kriegsmarine style
        when Int { @connections = @connections.deepmap(* - 1) }

        # Note: Both styles have the same internal reprentation.
    }


    return $pb.bless(
        wiring_str   => $setting,
        wiring_pairs => @connections,
    );
}

submethod TWEAK() {
    
    # enforce maximum number of pairs.
    if @!wiring_pairs > $MAX-PAIR {
        X::Error.new(
            reason => 'Number of pairs exceed 10',
            source => +@!wiring_pairs,
            suggestion => 'Provide at most 10 pairs',
        ).throw;
    }

    my $counter = bag @!wiring_pairs.duckmap(|*);
    my $set     = set @!wiring_pairs.duckmap(|*);
    my %repeated-elems = %($counter (-) $set);


    if %repeated-elems {
        X::Error.new(
            # Not sure if it's worth it to put it back in the H/L o K style again.
            # Use internal representation of pairs instead.
            reason => 'Duplicate (internal) connections', 
            source => %repeated-elems.keys.sort,
            suggestion => 'Make sure a path occurs at most once',
        ).throw;
    }

    # Make transposition of pairs.
    for @!wiring_pairs.Str.comb(/\d+/) -> $m, $n {
        # Make sure the pair ($m, $n) is in the set of unique pairs.
        unless (($m.Int, $n.Int).Set,) (<) $CONNECTIONS {
            X::Error.new(
                reason => 'Invalid connection',
                source => ($m, $n),
                suggestion => 'Provide a valid pair',
            ).throw;
        }

        =comment
        @a = [0, 1, 2, 3, ..., 25]
        (1, 3) => (@a[1], @[3]) = (3, 1)
        @a = [0, 3, 2, 1, ..., 25]

        (@!wiring_map[$m], @!wiring_map[$n]) = ($n, $m);
    }

}

# Returns array with swapped pairs (if any).
method get-wiring-map( --> Array ) { @!wiring_map }


# Returns the connections as a set of 2-tuples.
method get-pairs( --> Set ) {
    
    my $pairs = set ();
    
    for ^26 -> $x {
        my $y = @!wiring_map[$x];
        next without $y;
        next if $x == $y; # This happens with straight mapping (index equals to value).

        my $pair = ($x.Int, $y.Int).Set;

        # If not element yet, add it to the set of pairs
        unless $pair (&) $pairs {
            $pairs = $pairs (|) ($pair, ); # comma added to avoid 
                                           # coercing .Set to .Set
        }
    }

    return $pairs;
}

# Return connections (sorted) as a string as found in 
# army key sheet (i.e., 'HO ME').
method army-str( --> Str ) {
    my $p = self.get-pairs();

    my @pairs = map {
        sort(
            chr($^b + 'A'.ord),
            chr($^a + 'A'.ord),
        ).join('')
    }, $p.Str.comb(/\d+/);

    return @pairs.sort.join(' ');
}

# Return connections (sorted) as a string as found in 
# navy key sheet (i.e., '8/15 13/5').
method navy-str( --> Str ) {
    my $p = self.get-pairs();

    my @pairs = map {
        sort($^b + 1, $^a + 1).join('/')
    }, $p.Str.comb(/\d+/);

    return @pairs.sort(+*).join(' ');

}

# Return corresponding element (either a swapping or just straight mapping).
method signal( Int $n where 0 <= $n <= 25 ) { 
    return @!wiring_map[$n]
}








=begin pod
=NAME ENIGMA::Machine::Plugboard

=head1 PREAMBLE

The plugboard allows the operator to swap letters before and after the 
entry wheel. This is accomplished by connecting cables between pairs of
plugs that are marked with letters (Heer & Luftwaffe models) or numbers
Kriegsmarine). Ten cables were issued with each machine; thus up to 10 of
these swappings could be used as part of a machine setup.

Each cable swaps both the input and output signals. Thus if A is connected
to B, A crosses to B in the keyboard to entry wheel direction and also in
the reverse entry wheel to lamp direction.

=SYNOPSIS

=begin code
use v6;
use ENIGMA::Machine::Plugboard;

# plugboard that represents the swapping
# 'A' <=> 'Z', 'E' <=> 'I' and 'J' <=> 'S'.
my $pb = Plugboard.new(setting => [(0, 25), (4, 8), (9, 18)]);


# using Heer/Luftwaffe syntax
my $pb-hl = Plugboard.from-key-sheet('AZ EI JS');

# using Kriegsmarine syntax
my $pb-k  = Plugboard.from-key-sheet('1/26 5/9 10/19');

=end code


=DESCRIPTION

The Plugboard class represents the Enigma Machine plugboard (Steckerbrett). 

=begin item
The C<new> constructor

The following is a description of the plugboard characteristics that can be
specified through the C<new> constructor:

=begin item
C<setting> - A list or array of 2-tuples of integer pairs.

An empty array or list can be used to indicate no plugboard connections are
to be used (i.e., a straight mapping A => A, B => B, etc). Alternatively, the
C<new> constructor can be called without arguments to achieve the same result.

If plugboard connections are to be used, a list or array of 2-tuples must be
provided. Each integer in the 2-tuple must be between 0-25 (inclusive). At most
10 such pairs can be specified. Each value represents an input/output path 
through the plugboard. It is invalid to specify the same path more than once in the
list.
=end item

=end item 

=begin item
The C<from-key-sheet> constructor

Similar to the C<new> method, the C<from-key-sheet> constructor can be used 
to create a Plugboard objects. However, instead of using a list of 2-tuples,
a setting string, as you may find on a key sheet, must be used.

Two syntaxes are supported:
=begin item
Heer/Luftwaffe

In this syntax, the setting is given as a string of alphabetic pairs.
For example: 'PO ML IU KJ NH YT GB VF RE DC'
=end item

=begin item
Kriegsmarine

In this syntax, the settings are given as a string of numeric pairs,
separated by a '/'. Note that the numbering uses 1-26, inclusive.
For example: '18/26 17/4 21/6 3/16 19/14 22/7 8/1 12/25 5/9 10/15'
=end item

To specify no plugboard connections, C<from-key-sheet> can be called with 
either an empty string or without an argument.

An error will be raised if the settings string is invalid, or if it contains 
more than MAX_PAIRS pairs. Each plug should be present at most once in the 
setting string.

=end item

=head1 METHODS

=head2 CONSTRUCTORS

method B<C<from-key-sheet>>

=begin code
method from-key-sheet( Str $setting = "" ) returns Plugboard
=end code

Creates a Plugboard object from a string of alphabetical or numeric pairs.

=head2 OTHER METHODS

method B<C<get-wiring-map>>

=begin code
method get-wiring-map() returns Array
=end code

Returns array with swapped pairs (if any).

method B<C<get-pairs>>

=begin code
method get-pairs() returns Set
=end code

Returns the connections as a set of 2-tuples.

method B<C<army-str>>

=begin code
method army-str() returns Str
=end code

Returns connections (sorted) as a string as found in an army key sheet (i.e., 'HO ME').

method B<C<navy-str>>

=begin code
method navy-str() returns Str
=end code

Returns connections (sorted) as a string as found in a navy key sheet (i.e., '8/15 13/5').

method B<C<signal>>

=begin code
method signal()
=end code

Returns corresponding element (either a swapping or just straight mapping.

=end pod
