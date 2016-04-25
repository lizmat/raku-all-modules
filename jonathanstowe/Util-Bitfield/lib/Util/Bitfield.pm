use v6;

=begin pod

=head1 NAME 

Util::Bitfield - Utility subroutines for working with bitfields

=head1 SYNOPSIS

=begin code

use Util::Bitfield;

my $number = 0b0001011101101010;

# source integer, number of bits, starting position, word size
say extract-bits($number,3,3,16); # 5
say sprintf "%016b",insert-bits(7, $number, 3, 3, 16); # "0001111101101010"

=end code


=head1 DESCRIPTION

"Bitfields" are common in hardware interfaces and
compact binary data formats, allowing the packing
of multiple fields of information within a single
machine word sized value for instance, hardware
examples might include device registers or gpio
ports, software examples include MP3 "frame headers".

Whilst highly efficient for data storage and
transmission, they're usually a pain to work with
in high level languages, requiring masking and
shifting of numbers possibly multiple times to
get a value you can sensibly use in your program.

Also because it's not something I at least tend
to do very frequently the patterns don't come
naturally and I end up starting from first principles
every time.

So to this end, on being presented with some data
that required unpacking of a bit field, I made this
fairly simple library to extract and insert an
arbitrary number of bits from an arbitrary location
within a larger integer as smaller integers.

=head1 SUBROUTINES

This module exports three subroutines by default.

It is assumed that the bit positions are indexed
from most significant bit (the left hand end,) at
position 0, I found it easier to think about it
this way round and it is typically the way most
descriptions of this kind of data are ordered
(though they may number the bits in the other
direction,)

Also if you are getting the data as individual bytes
and constructing a larger word from them then care
may be needed to determine the correct "endianess"
of the data when combining the bytes into a Perl
Int.

=head2 extract-bits

    sub extract-bits(Int $value, Int $bits, Int $start = 0, Int $word-size = 32)

This extracts the C<$bits> number of bits as an L<Int> starting at the 0 indexed
position from the Int C<$value>.  The correct word size in bits should be
supplied if it is other than 32 (an arbitrary choice based on what was most
common in what I was working on,) this should be the native or source bit size
of the structure that holds the data (e.g.the MP3 frame header is the first
4 bytes,) it is typical this will be some even multiple of 8.

=head2 insert-bits

    sub insert-bits(Int $ins, Int $value, Int $bits, Int $start = 0, Int $word-size = 32)

This inserts the Int C<$ins> into C<$value> as the stated number of bits at the
position C<$start>.  If the value to be inserted would overflow a number of
C<$bits> bits an exception will be thrown. As with C<extract-bits> C<$word-size> should
represent the documented number of bits in the source.

=head2 make-mask

    sub make-mask(Int $bits, Int $start = 0, Int $word-size = 32, Bool :$invert)

This is used internally but may be useful depending on your requirements, it
returns the "bit mask" that isolates the value of C<$bits> length starting
at C<$start> (as above zero indexed from most significant bit,) in the 
value of C<$word-size> bits.  Typically this mask would be 'anded' with 
the incoming value and the result shifted right by the appropriate number of
bits to get the actual value.  The C<:invert> adverb is provided to make
the inverse mask (i.e. zero the selected range) that would be used when
inserting the data.

=head2 split-bits

    sub split-bits(Int $bits, Int $value where { $_ < 2**$bits })

This returns an array of C<$bits> length representing the bits comprising
C<$value> which must be an integer value that would fit into the number
of bits without overflowing.

=end pod


module Util::Bitfield:ver<0.0.2>:auth<github:jonathanstowe> {

    class X::BitOverflow is Exception {
        has Int $.value is required;
        has Int $.width is required;
        method message() returns Str {
            "Value '{ $!value }' would overflow bitfield of '{ $!width }' bits";
        }
    }

    sub make-mask(Int $bits, Int $start = 0, Int $word-size = 32, Bool :$invert) is export(:DEFAULT) {
	    my $ret = (((1 +< $bits) - 1) +< ($word-size - ($bits + $start)));

        if $invert {
            $ret = ((2 ** $word-size) - 1) +^ $ret;
        }

        $ret;
    }

    sub extract-bits(Int $value, Int $bits, Int $start = 0, Int $word-size = 32) is export(:DEFAULT){
	    ($value +& make-mask($bits, $start, $word-size)) +> ( $word-size - ( $bits + $start));
    }

    sub insert-bits(Int $ins, Int $value, Int $bits, Int $start = 0, Int $word-size = 32) is export(:DEFAULT) {
        if $ins > (2**$bits) - 1 {
            X::BitOverflow.new(value => $ins, width => $bits).throw;
        }

        ($value +& make-mask($bits, $start, $word-size, :invert)) +| ( $ins +< ($word-size - ($bits + $start)));
    }

    sub split-bits(Int $bits, Int $value where { $_ < 2**$bits }) is export(:DEFAULT) {
	    my @bits;
	    for ^$bits -> $j {
		    my $k = ( $bits - 1) - $j;
		    @bits[$k] = ($value +& ( 1 +< $j)) ?? 1 !! 0;
	    }
	    @bits;
    }


}
# vim: expandtab shiftwidth=4 ft=perl6
