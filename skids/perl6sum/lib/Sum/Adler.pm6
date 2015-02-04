
use Sum;

=NAME Sum::Adler - Fletcher and Adler roles for Sum::

=begin SYNOPSIS
=begin code
    use Sum::Adler;

    class AdlerSum does Sum::Adler32 does Sum::Marshal::Raw { }
    my AdlerSum $a .= new();
    $a.finalize(0..255).fmt('%x').say; # adf67f81
=end code
=end SYNOPSIS

# This is a bit of a hack.  We want the test suite to be able to try to
# run the code in the synopsis.  When pod is more functional maybe this
# will become more maintainable.  In the meantime, if you edit anything
# above, take care to adjust the sections here.

# Disabling this for now until .pir files properly serialize pod
#$Sum::Adler::Doc::synopsis = $=pod[0].content[4].content.Str;

=begin DESCRIPTION
    Using C<Sum::Adler> defines roles for generating types of C<Sum>
    that calculate variations of the Fletcher and Adler checksums.

    These are rather old algorithms which have fallen out of general
    use.  However, they persist in several network protocols.
=end DESCRIPTION

=begin pod

=head1 ROLES

=head2 role Sum::Fletcher [ :$modulusA = 65535, :$modulusB = $modulusA,
                            :$inivA = 0, :$inivB = 0, :$finv = False,
                            :$columnsA = 16, :$columnsB = $columnsA ]

    The C<Sum::Fletcher> role helps one to define types of C<Sum>
    implementing custom variations of a Fletcher checksum.  The
    other roles described below are just compositions of this role
    with prechosen parameter values.

    Fletcher sums maintain two accumulators, which are concatinated
    bitwise to produce a result.  One accumulator is a simple modulus
    sum of each addend.  This modulus can be set with the C<$modulusA>
    parameter.  It appears in the least significant bits of the result,
    and the number of bit positions to use for this value is controlled
    by the C<$columnsA> parameter.

    The second accumulator sums the partial sums of the first accumulator,
    also in modulo.  The modulus used in this accumulator is usually
    the same as the modulus used in the first accumulator, but may be
    set independently with the C<$modulusB>.  This accumulator is stored
    in the most significant bits of the result.  The number of bits to
    use to contain this value is usually the same as that of the other
    accumulator, but may be set independently with the C<$columnsB>
    parameter.

    When C<:finv> is specified, the final result is bitwise inverted.
    When a non-boolean value is specified for C<$finv>, the remainder
    and this value are combined in a bitwise XOR when a result is
    finalized.

    When a non-boolean value is specified for C<$inivA> or C<$inivB>,
    the corresponding accumulator is initialized to the provided value
    when a new object is instantiated.

    All these sums keep no positional state, so C<.pos> and C<.elems>
    are not provided by the base role.  They also retain all state
    after finalization, and C<Sum::Partial> is premixed.

=end pod

class X::Sum::CheckVals is Exception {
    method message {
        "The parameters of this Sum preclude the use of check values."
    }
}

role Sum::Fletcher [ :$modulusA = Any, :$modulusB = Any,
                     :$inivA = 0, :$inivB = 0, :$finv = False,
                     :$columnsA = Any, :$columnsB = Any ]
     does Sum::Partial {

# rakudo-m has some problems with default values.  After Adler32
# composes this role, subsequent classes that use it get cached values somehow.
#                     :$columnsA = 16, :$columnsB = $columnsA
#                     :$modulusA = 65535, :$modulusB = $modulusA,

     my $cA = $columnsA;
     $cA //= 16;
     my $cB = $columnsB;
     $cB //= $cA;

     my $mA = $modulusA;
     $mA //= 65535;
     my $mB = $modulusB;
     $mB //= $mA;

    has Int $!A = ( ($inivA.WHAT === Bool)
                     ?? (-$inivA +& ((1 +< $cA)-1))
                     !! $inivA );
    has Int $!B  = ( ($inivB.WHAT === Bool)
                      ?? (-$inivB +& ((1 +< $cB)-1))
                      !! $inivB );

    method size () { $cA + $cB }

    method add (*@addends) {
        # TODO: when native type support improves, use effecient
        # types on the accumulators, and allow the sums
        # to accumulate as long as they do not overflow to
        # save on modulus operations.

        # Also better native type support might allow Adler32
        # to warn if it is used with word/doubleword addends,
        # by adding :accept/:coerce parameters.

        for (@addends) -> $a {
            $!A += $a;
            $!A %= $mA;
            $!B += $!A;
            $!B %= $mB;
        }
        return;
    };

    method finalize(*@addends) {
        self.push(@addends);

        # If/when we stop doing a modulus every round we'll need to do this.
        $!A %= $mA;
        $!B %= $mB;

	my $res = ($!B +< $cA) +| $!A;
        if $finv {
            return $res +^ ((1 +< ($cA + $cB)) - 1)
                if $finv.WHAT === Bool;
            return $res +^ $finv;
	}
	$res;
    }
    method Numeric () { self.finalize };

    method buf8 () {
        my $f = self.finalize;
        my $bytes = ($cA + $cB + 7) div 8;
        buf8.new($f X+> (8 X* reverse(^$bytes)));
    }
    method buf1 () {
        my $f = self.finalize;
        Buf.new( 1 X+& ($f X+> reverse(^($cA + $cB))) );
    }
    method blob8 () {
        my $f = self.finalize;
        my $bytes = ($cA + $cB + 7) div 8;
        blob8.new($f X+> (8 X* reverse(^$bytes)));
    }
    method blob1 () {
        my $f = self.finalize;
        Blob.new( 1 X+& ($f X+> reverse(^($cA + $cB))) );
    }
    # Although these algorithms can produce results not evenly packable,
    # common cases are packable and users will expect byte results.
    method Buf () {
        (($cA + $cB) % 8) ?? self.buf1 !! self.buf8
    }
    method Blob () {
        (($cA + $cB) % 8) ?? self.blob1 !! self.blob8
    }

    method checkvals(*@addends) {
        self.finalize(@addends);
        return fail(X::Sum::CheckVals.new()) if $mB > $mA;

        # TODO: in the case of Adler these are impossible because of the addend
        # size.  We are agnostic to that.  So the values we return may
        # end up being larger than bytes.  We should probably warn instead.

        my $wantCB = $mB - $!B;
        my $msv = $mA + $wantCB - $!A;
        $msv -= $mA if $msv > $mA;

        ($msv, $mA - $wantCB)
    }

}


=begin pod

=head2 role Sum::Adler32
       does Sum::Fletcher[ :inivA(1) :modulusA(65521) :columnsA(16) ] { }

    The C<Sum::Adler32> parametric role is used to create a type of C<Sum>
    that calculates an Adler32 checksum.

    The resulting C<Sum> expects values that will numerically coerce to
    single byte addends.  A C<Sum::Marshal::*> role must be mixed into
    the class, and some such roles may also be used to properly process
    wider or narrower addends as appropriate to the application.

    Note that the C<.checkvals> method is not intended for use when
    the number of bits in the addends is lower than the number of bits in the
    accumulators.  The results of this method in a C<Sum::Adler32>
    will likely not be expressable in bytes.

=end pod

role Sum::Adler32
     does Sum::Fletcher[ :inivA(1) :modulusA(65521) :columnsA(16) ] { }

=begin pod

=head2 role Sum::Fletcher16
     does Sum::Fletcher[ :modulusA(255) :columnsA(8) ]

    This role calculates the Fletcher16 checksum and expects byte addends.

=end pod

role Sum::Fletcher16
     does Sum::Fletcher[ :modulusA(255) :columnsA(8) ] { }

=begin pod

=head2 role Sum::Fletcher32
     does Sum::Fletcher[ ]

    This role calculates the Fletcher32 checksum and expects 16-bit addends.
    Mixing an appropriate C<Sum::Marshal> role may help deal with padding
    and endianness issues.

=end pod

role Sum::Fletcher32
     does Sum::Fletcher[ ] { }

=begin pod

=head2 role Sum::Fletcher64
     does Sum::Fletcher[ :modulusA(4294967295) :columnsA(32) ]

    This role calculates the Fletcher64 checksum and expects 32-bit addends.
    Mixing an appropriate C<Sum::Marshal> role may help deal with padding
    and endianness issues.

=end pod

role Sum::Fletcher64
     does Sum::Fletcher[ :modulusA(4294967295) :columnsA(32) ] { }

=begin pod

=head1 METHODS

=head2 method checkvals(*@addends)

    The sum is finalized after providing the given addends, then two
    values are calculated which would result in a zero checksum over
    the original data appended with these two values.

    Note that it is possible to construct Fletcher style checksums that
    cannot have such values.  In particular if C<$modulusA> is smaller
    than C<$modulusB>, check values cannot be constructed for all types
    of datum.  In this case this method will return an unthrown
    C<X::Sum::CheckVals>.

    Another situation arises when a Fletcher style sum is calculated
    using a modulus larger than one more than the maximum value of an
    addend.  This is the case in Adler32 sums.  Since addends are too
    small to contain one half of the resulting checksum, they cannot
    always contain the check values needed to produce a zero checksum.
    This condition is neither currently detected nor warned about.

=end pod

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2012 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=begin REFERENCES
=item RFC 905 Annex B L<https://tools.ietf.org/html/rfc905>
=item RFC 2960 L<https://www.rfc-editor.org/info/rfc2960>
=end REFERENCES

=SEE-ALSO C<Sum::(pm3)>

