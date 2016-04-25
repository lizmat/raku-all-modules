use v6.c;

=begin pod

=head1 NAME

EuclideanRhythm - create rhythmic patterns based on the Euclidean algorithm

=head1 SYNOPSIS

=begin code

use EuclideanRhythm;

my $r = EuclideanRhythm.new(slots => 16, fills => 7);

for $r.list {
    # do something if the value is True
}

=end code

=head1 DESCRIPTION

This provides an implementation of the algorithm described in
L<http://cgm.cs.mcgill.ca/~godfried/publications/banff.pdf> which is
in turn derived from a Euclidean algorithm.  Simply put it provides a
simple method to distribute a certain number of "fills" (hits, beats,
notes or whatever you want to call them,) as evenly as possibly among a
number of "slots".  The linked paper describes how, using this method,
you can approximate any number of common rhythmic patterns (as well as
not so common ones.)

You could of course use it for something other than generating
musical rhythms: any requirement where a number of events need to be
distributed over a fixed number of slots may find this useful.

=head1 METHODS

=head2 method new

    method new(Int :$slots!, Int :$fills!)

The constructor has two required named arguments. The total number
of C<slots> to be filled, and the number of C<fills> which are to be
distributed into them.  The number of fills should not be larger than
the number of slots.  The C<slots> could be thought of as being the total
number of "beats" in a measure (or bar,) but does not necessarily have to
be an even number at all. Obviously if you are using more than one object
to create a rhythmic structure you may want to either arrange things such
that either the C<slots> of each have some common multiple or adjust the
timing of the slots such that it can resolve over time to the same length.

=head2 method once

    method once()

This returns a C<slots> sized array, filled appropriately.

=head2 method list

    method list()

This is an infinite lazy list of the calculated pattern and is probably
the more useful interface, obviously this is produced as fast as 
possible so if you are using it to generate events which you care about
the timing of then you will need to take care of the timing yourself.

=end pod


class EuclideanRhythm {
    has Int $.slots is required;
    has Int $.fills is required;

    has @!count;
    has @!remainder;
    has $!level;

    method !bitmap(Int $level, @count, @remainder ) { 
   
        if $level == -1 {
            take False;
        }
        elsif  $level == -2 {
            take True;
        }
        else {
            if @remainder[$level] != 0 {     
                self!bitmap($level - 2, @count, @remainder); 
            }
            for 0 .. @count[$level] - 1 {
                self!bitmap($level - 1, @count, @remainder); 
            }
        }
    }

    submethod BUILD(Int :$!slots, Int :$!fills where * <= $!slots, Int :$rotate = 0) {
        my $divisor = $!slots - $!fills;
        @!remainder[0] = $!fills; 
        $!level = 0; 
        while @!remainder[$!level] > 1 { 
            @!count[$!level] = $divisor / @!remainder[$!level]; 
            @!remainder[$!level+1] = $divisor % @!remainder[$!level]; 
            $divisor = @!remainder[$!level]; 
            $!level++;
        }
        @!count[$!level] = $divisor; 

    }

    method list() {
        gather {
            loop {
                self!bitmap($!level, @!count, @!remainder);
            }
        }
    }
   
   
    method once() {
         do gather { self!bitmap($!level, @!count, @!remainder) }; 
    } 
}

# vim: expandtab shiftwidth=4 ft=perl6
