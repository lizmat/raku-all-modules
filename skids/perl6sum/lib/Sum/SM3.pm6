=NAME Sum::SM3 - SM3 checksum family roles for Sum::

=begin SYNOPSIS
=begin code
    use Sum::SM3;

    # We have very few test vectors for SM3.  Use with caution.
    class mySM3 does Sum::SM3 does Sum::Marshal::Raw { }
    my mySM3 $a .= new();
    $a.finalize("abc".encode('ascii')).fmt.say;
       # 66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0

=end code
=end SYNOPSIS

# This is a bit of a hack.  We want the test suite to be able to try to
# run the code in the synopsis.  When pod is more functional maybe this
# will become more maintainable.  In the meantime, if you edit anything
# above, take care to adjust the sections here.

$Sum::SM3::Doc::synopsis = $=pod[1].contents[0].contents.Str;

=begin DESCRIPTION

    Using C<Sum::SM3> defines roles for generating types of C<Sum> that
    implement the SM3 standard hash function used for Chinese government
    and commerical interests.

    SM3 sums can be computationally intense.  They also require a small
    but significant memory profile while not finalized, so care must be
    taken when huge numbers of concurrent instances are used.

    NOTE: This implementation is unaudited and is for experimental
    use only.  When audits will be performed will depend on the maturation
    of individual Perl6 implementations, and should be considered
    on an implementation-by-implementation basis.

=end DESCRIPTION

=begin pod

=head1 ROLES

=head2 role Sum::SM3 [ :$recourse = True ] does Sum::MDPad

    The C<Sum::SM3> parametric role is used to create a type of C<Sum>
    that calculates a SM3 message digest.

    When C<:!recourse> is used, pure Perl 6 code is used directly.
    The resulting classes behave as described in C<Sum::MDPad>,
    which means they have rather restrictive rules as to the type
    and number of provided addends when used with C<Sum::Marshal::Raw>.

    Mixing a C<Sum::Marshal::Block> role is recommended except for
    implementations that wish to optimize performance.

    When C<:recourse> is defined (the default), SM3 will still use
    pure Perl 6 code, because currently there is no C implementation
    to use.  However, it will behave the same as a typical C
    implementation would, e.g. the class will not support messages
    that do not pack into bytes evenly, and there is no need to mix
    C<Sum::Marshal::Block>.

    The default precedence of C libraries may be adjusted from time
    to time to prefer the best performing implementation.  To set your
    own preferences, build your own class mixing C<Sum::Recourse>.

    The block size used is 64 bytes.

    Note that there are only two test vectors published with the
    english version of the specification, so testing and verification
    of this module is not especially thorough.

=end pod

use Sum;
use Sum::Recourse;
use Sum::MDPad;

role Sum::SM3 [ :$recourse where { not $_ }
                                             = True ]
     does Sum::MDPad[ :lengthtype<uint64_be> :!overflow ] {

    has @!W;     # message "extension" gets bound here.
    has @!V =    # Current hash state.
        (0x7380166f, 0x4914b2b9, 0x172442d7, 0xda8a0600,
         0xa96f30bc, 0x163138aa, 0xe38dee4d, 0xb0fb0e4e);
    method size ( --> int) { 256 }

    # A moment of silence for the pixies that die every time something
    # like this gets written in an HLL.
    my sub rol ($v, $count is copy) {
        $count +&= 31;
        ($v +< $count) +& 0xffffffff +| (($v +& 0xffffffff) +> (32 - $count));
    }

    method comp ( --> Nil) {
        my ($A, $B, $C, $D, $E, $F, $G, $H) = @!V[];

	my sub P0 ($X) { [+^] $X, rol($X, 9), rol($X, 17) }

        for ((0x79cc4519,
              -> $X, $Y, $Z { [+^] $X, $Y, $Z },
              -> $X, $Y, $Z { [+^] $X, $Y, $Z }).item xx 16,
             (0x7a879d8a,
              -> $X, $Y, $Z { [+|] ($X, $X, $Y) Z+& ($Y, $Z, $Z) },
              -> $X, $Y, $Z { [+|] ($X, +^$X) Z+& ($Y, $Z) }).item xx 48).kv
            -> $j,($T,$FF,$GG) {
	    my $SS1 = [+] rol($A,12), $E, rol($T, $j);
	    $SS1 +&= 0xffffffff;
            $SS1 = rol($SS1, 7);
	    my $SS2 = $SS1 +^ rol($A, 12);
            my $TT1 = $FF($A,$B,$C) + $D + $SS2 + @!W[68 + $j];
	    $TT1 +&= 0xffffffff;
            my $TT2 = $GG($E,$F,$G) + $H + $SS1 + @!W[$j];
	    $TT2 +&= 0xffffffff;
	    ($D, $C, $B, $A, $H, $G, $F, $E) =
	    ($C, rol($B, 9), $A, $TT1, $G, rol($F, 19), $E, P0($TT2));
        }
        @!V[] = @!V[] Z+^ (0xffffffff X+& ($A,$B,$C,$D,$E,$F,$G,$H));
	return; # This should not be needed per S06/Signatures
    }

    multi method add (blob8 $block where { .elems == 64 }) {

        return Failure.new(X::Sum::Final.new()) if $.final;

        # Update the length count and check for problems via Sum::MDPad
        given self.pos_block_inc {
            when Failure { return $_ };
        }

        # Explode the message block into a scratchpad

        # First 16 uint32's are a straight copy of the data.
        # When endianness matches and with native types,
        # this would boil down to a simple memcpy.
        my @W = (:256[ $block[ $_ ..^ $_+4 ] ] for 0,4 ...^ 64);

        # Fill the rest of the scratchpad with permutations.
	my sub P1 ($X) { [+^] $X, rol($X, 15), rol($X, 23) }

        @W.push([+^]
                P1([+^] @W[*-16,*-9], rol(@W[*-3], 15)),
                rol(@W[*-13], 7),@W[*-6])
            for 16..67;
        @W.push([+^] @W[*-68,*-64]) for 0..63;

        @!W := @W;
        self.comp;
    }

    method Numeric {
        self.finalize;
        # This does not work yet on 32-bit machines
        # :4294967296[@!s[]]
        [+|] (@!V[] Z+< (224,192...0))
    }
    method Int () { self.Numeric }
    method bytes_internal {
        @!V[] X+> (24,16,8,0);
    }
    method buf8 {
        self.finalize;
        buf8.new(self.bytes_internal)
    }
    method blob8 {
        self.finalize;
        blob8.new(self.bytes_internal)
    }
    method Buf { self.buf8 }
    method Blob { self.blob8 }
}

my class PureSM3 does Sum::SM3[:!recourse] does Sum::Recourse::Marshal { }
role Sum::SM3[ :$recourse where { $_ == True }
                                               = True ] does Sum does Sum::Recourse[:recourse[:Perl6(PureSM3)]] { }


=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2015 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=begin REFERENCES
=item "SM3 Hash function" (Shen, Lee) L<https://tools.ietf.org/html/draft-shen-sm3-hash-01>

=end REFERENCES

=SEE-ALSO C<Sum::(pm3)>

