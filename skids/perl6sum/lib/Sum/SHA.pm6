=NAME Sum::SHA - SHA checksum family roles for Sum::

=begin SYNOPSIS
=begin code
    use Sum::SHA;

    class mySHA1 does Sum::SHA1 does Sum::Marshal::Raw { }
    my mySHA1 $a .= new();
    $a.finalize("123456789".encode('ascii')).say;
       # 1414485752856024225500297739715962456813268251713

    # SHA-224
    class mySHA2 does Sum::SHA2[:columns(224)] does Sum::Marshal::Raw { }
    my mySHA2 $b .= new();
    $b.finalize("123456789".encode('ascii')).say;
       # 16349067602210014067037177823623301242625642097093531536712287864097

    # When dealing with obselete systems that use SHA0
    class mySHA0 does Sum::SHA1[:insecure_sha0_obselete]
        does Sum::Marshal::Raw { }
    my mySHA0 $c .= new();
    $c.finalize("123456789".encode('ascii')).say;
       # 1371362676478658660830737973868471486175721482632
=end code
=end SYNOPSIS

# This is a bit of a hack.  We want the test suite to be able to try to
# run the code in the synopsis.  When pod is more functional maybe this
# will become more maintainable.  In the meantime, if you edit anything
# above, take care to adjust the sections here.

# Disabling this for now until .pir files properly serialize pod
#$Sum::SHA::Doc::synopsis = $=pod[0].content[3..6]>>.content.Str;

=begin DESCRIPTION
    Using C<Sum::SHA> defines roles for generating types of C<Sum> that
    implement the widely used SHA1 and SHA2 cryptographic hash function
    families.  It is also possible to calculate legacy SHA0 checksums,
    which are obselete and not cryptographically secure.

    SHA sums can be computationally intense.  They also require a small
    but significant memory profile while not finalized, so care must be
    taken when huge numbers of concurrent instances are used.

    NOTE: This implementation is unaudited and is for experimental
    use only.  When audits will be performed will depend on the maturation
    of individual Perl6 implementations, and should be considered
    on an implementation-by-implementation basis.
=end DESCRIPTION

=begin pod

=head1 ROLES

=head2 role Sum::SHA1 [ :$insecure_sha0_old = False ] does Sum::MDPad

    The C<Sum::SHA1> parametric role is used to create a type of C<Sum>
    that calculates a SHA1 message digest.  A SHA0 may be calculated
    instead if C<:insecure_sha0_old> is specified.

    Classes using these roles behave as described in C<Sum::MDPad>,
    which means they have rather restrictive rules as to the type
    and number of provided addends when used with C<Sum::Marshal::Raw>.
    The block size used is 64 bytes.

    Mixing a C<Sum::Marshal::Block> role is recommended except for
    implementations that wish to optimize performance.

=end pod

use Sum;
use Sum::MDPad;

role Sum::SHA1 [ Bool :$insecure_sha0_obselete = False ]
     does Sum::MDPad[ :lengthtype<uint64_be> :!overflow ] {

    has @!w;     # "Parsed" message gets bound here.
    has @!s =    # Current hash state.  H in specification.
        (0x67452301,0xEFCDAB89,0x98BADCFE,0x10325476,0xC3D2E1F0);

    method size ( --> int) { 160 }

    method comp ( --> Nil) {
        my ($a, $b, $c, $d, $e) = @!s[];

        for ((0x5A827999,{ $b +& $c +| +^$b +& $d }).item xx 20,
             (0x6ED9EBA1,{ $b +^ $c +^ $d }).item xx 20,
             (0x8F1BBCDC,{ $b +& $c +| $b +& $d +| $c +& $d }).item xx 20,
             (0xCA62C1D6,{ $b +^ $c +^ $d }).item xx 20).kv
            -> $i,($k,$f) {
            ($b,$c,$d,$e,$a) =
                ($a, rol($b,30), $c, $d,
                 0xffffffff +& (rol($a,5) + $f() + $e + $k + @!w[$i]));
        }
        @!s[] = 0xffffffff X+& (@!s[] Z+ (0xffffffff X+& ($a,$b,$c,$d,$e)));
	return; # This should not be needed per S06/Signatures
    }
    # A moment of silence for the pixies that die every time something
    # like this gets written in an HLL.
# rakudo-p in star 2014.8 cannot handle these sized types when running from PIR
#    my sub rol (uint32 $v, int $count where 0..32, --> uint32) {
    my sub rol ($v, $count where 0..32) {
        ($v +< $count) +& 0xffffffff +| (($v +& 0xffffffff) +> (32 - $count));
    }

    multi method add (blob8 $block where { .elems == 64 }) {

        # Update the length count and check for problems via Sum::MDPad
        given self.pos_block_inc {
            when Failure { return $_ };
        }

        # Explode the message block into a scratchpad

        # First 16 uint32's are a straight copy of the data.
        # When endianness matches and with native types,
        # this would boil down to a simple memcpy.
        my @m = (:256[ $block[ $_ ..^ $_+4 ] ] for 0,4 ...^ 64);

        # Fill the rest of the scratchpad with permutations.
        @m.push(rol(([+^] @m[* «-« (3,8,14,16)]),+!$insecure_sha0_obselete))
            for 16..^80;

        @!w := @m;
        self.comp;
    };

    method finalize(*@addends) {
        given self.push(@addends) {
            return $_ unless $_.exception.WHAT ~~ X::Sum::Push::Usage;
        }

        self.add(self.drain) if self.^can("drain");

        self.add(blob8.new()) unless $.final;

        # This does not work yet on 32-bit machines
        # :4294967296[@!s[]];
        [+|] (@!s[] Z+< (128,96...0));
    }
    method Numeric { self.finalize };
    method bytes_internal {
        @!s[] X+> (24,16,8,0);
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

=begin pod

=head2 role Sum::SHA2 [ :$columns = 256 ] does Sum::MDPad

    The C<Sum::SHA2> parametric role is used to create a type of C<Sum>
    that calculates a SHA2 message digest.

    The C<$columns> parameter selects the SHA2 hash variant, and may
    be 224, 256, 384, or 512, yielding SHA-224, SHA-256, SHA-384, or
    SHA-512 respectively.

    Classes using these roles behave as described in C<Sum::MDPad>,
    which means they have rather restrictive rules as to the type
    and number of provided addends when used with C<Sum::Marshal::Raw>.
    The block size used is 64 bytes, or 128 when C<$columns> is 384 or 512.

    Mixing a C<Sum::Marshal::Block> role is recommended except for
    implementations that wish to optimize performance.

=end pod

use Sum;
use Sum::MDPad;

my @Sum::SHA::k64 =
  0x428a2f98d728ae22,0x7137449123ef65cd,0xb5c0fbcfec4d3b2f,0xe9b5dba58189dbbc,
  0x3956c25bf348b538,0x59f111f1b605d019,0x923f82a4af194f9b,0xab1c5ed5da6d8118,
  0xd807aa98a3030242,0x12835b0145706fbe,0x243185be4ee4b28c,0x550c7dc3d5ffb4e2,
  0x72be5d74f27b896f,0x80deb1fe3b1696b1,0x9bdc06a725c71235,0xc19bf174cf692694,
  0xe49b69c19ef14ad2,0xefbe4786384f25e3,0x0fc19dc68b8cd5b5,0x240ca1cc77ac9c65,
  0x2de92c6f592b0275,0x4a7484aa6ea6e483,0x5cb0a9dcbd41fbd4,0x76f988da831153b5,
  0x983e5152ee66dfab,0xa831c66d2db43210,0xb00327c898fb213f,0xbf597fc7beef0ee4,
  0xc6e00bf33da88fc2,0xd5a79147930aa725,0x06ca6351e003826f,0x142929670a0e6e70,
  0x27b70a8546d22ffc,0x2e1b21385c26c926,0x4d2c6dfc5ac42aed,0x53380d139d95b3df,
  0x650a73548baf63de,0x766a0abb3c77b2a8,0x81c2c92e47edaee6,0x92722c851482353b,
  0xa2bfe8a14cf10364,0xa81a664bbc423001,0xc24b8b70d0f89791,0xc76c51a30654be30,
  0xd192e819d6ef5218,0xd69906245565a910,0xf40e35855771202a,0x106aa07032bbd1b8,
  0x19a4c116b8d2d0c8,0x1e376c085141ab53,0x2748774cdf8eeb99,0x34b0bcb5e19b48a8,
  0x391c0cb3c5c95a63,0x4ed8aa4ae3418acb,0x5b9cca4f7763e373,0x682e6ff3d6b2b8a3,
  0x748f82ee5defb2fc,0x78a5636f43172f60,0x84c87814a1f0ab72,0x8cc702081a6439ec,
  0x90befffa23631e28,0xa4506cebde82bde9,0xbef9a3f7b2c67915,0xc67178f2e372532b,
  0xca273eceea26619c,0xd186b8c721c0c207,0xeada7dd6cde0eb1e,0xf57d4f7fee6ed178,
  0x06f067aa72176fba,0x0a637dc5a2c898a6,0x113f9804bef90dae,0x1b710b35131c471b,
  0x28db77f523047d84,0x32caab7b40c72493,0x3c9ebe0a15c9bebc,0x431d67c49c100d4c,
  0x4cc5d4becb3e42b6,0x597f299cfc657e2a,0x5fcb6fab3ad6faec,0x6c44198c4a475817;

my @Sum::SHA::k32 = @Sum::SHA::k64.list X+> 32;

role Sum::SHA2common {
    has @.w is rw;                   # "Parsed" message gets bound here.
    has @.s is rw = self.init();     # Current hash state.  H in specification.

    multi method add (blob8 $block where { .elems == self.bsize/8 }) {
        # Update the length count and check for problems via Sum::MDPad
        given self.pos_block_inc {
            when Failure { return $_ };
        }
        self.scratchpad($block);
        self.comp;
    };

    method finalize(*@addends) {
        given self.push(@addends) {
            return $_ unless $_.exception.WHAT ~~ X::Sum::Push::Usage;
        }
        self.add(self.drain) if self.^can("drain");
        self.add(blob8.new()) unless $.final;
        self.Int_internal;
    }
    method Numeric { self.finalize };

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

role Sum::SHAmix32 does Sum::SHA2common {
    my @k := @Sum::SHA::k32;

    # A moment of silence for the pixies that die every time something
    # like this gets written in an HLL.
    my sub infix:<ror> ($v, int $count where 0..32, --> uint32) {
        [+|] (0xffffffff +& $v) +> $count, 0xffffffff +& ($v +< (32 - $count));
    }

    method bsize { 512 };

    method scratchpad ($block --> Nil) {
        my @m;

        # First 16 uint32's are a straight copy of the data.
        # When endianness matches and with native types,
        # this would boil down to a simple memcpy.
        @m = (:256[ $block[ $_ ..^ $_+4 ] ] for 0,4 ...^ 64);

        # Fill the rest of the scratchpad with permutations.
        @m.push(0xffffffff +& (
                [+] @m[*-16,*-7],
                ([+^] ((@m[*-15] Xror (7,18)),  @m[*-15] +> 3 )),
                ([+^] ((@m[*-2]  Xror (17,19)), @m[*-2]  +> 10))
                )) for 16..^64;
	@.w = @m;
	return; # This should not be needed per S06/Signatures
    }

    method comp (--> Nil) {
        my ($a,$b,$c,$d,$e,$f,$g,$h) = @.s[];
        for ^64 -> $i {
            # We'll mask this below
            my $t1 = [+] $h, @k[$i], @.w[$i],
                         ($g +^ ($e +& ($f +^ $g))),
                         ([+^] ($e Xror (6,11,25)));
            # We'll mask this below
            my $t2 = [+] ([+^] ($a Xror (2,13,22))),
                         ([+^] (($a,$a,$b) >>+&<< ($b,$c,$c)));

            ($a,$b,$c,$d,$e,$f,$g,$h) =
                0xffffffff +& ($t1 + $t2), $a, $b, $c,
                0xffffffff +& ($d + $t1), $e, $f, $g;
        }
        # merge the new state
        @.s[] = 0xffffffff
                X+&
                (@.s[] Z+ (0xffffffff X+& ($a,$b,$c,$d,$e,$f,$g,$h)));
	return; # This should not be needed per S06/Signatures
    }
}
role Sum::SHAmix64 does Sum::SHA2common {
    my @k := @Sum::SHA::k64;

    # A moment of silence for the pixies that die every time something
    # like this gets written in an HLL.
    my sub infix:<ror> ($v, int $count where 0..64, --> uint64) {
       [+|] ($v +& 0xffffffffffffffff) +> $count,
            ($v +< (64 - $count)) +& 0xffffffffffffffff;
    }

    method bsize { 1024 };

    method scratchpad ($block --> Nil) {
        my @m;

        # First 16 uint64's are a straight copy of the data.
        # When endianness matches and with native types,
        # this would boil down to a simple memcpy.
        @m = (:256[ $block[ $_ ..^ $_+8 ] ] for 0,8 ...^ 128);

        # Fill the rest of the scratchpad with permutations.
        @m.push(0xffffffffffffffff +& (
                [+] @m[*-7,*-16],
                ([+^] ((@m[*-15] Xror (1,8)),  @m[*-15] +> 7 )),
                ([+^] ((@m[*-2]  Xror (19,61)),@m[*-2]  +> 6))
                )) for 16..^80;
	@.w = @m;
	return; # This should not be needed per S06/Signatures
    }

    method comp (--> Nil) {
        my ($a,$b,$c,$d,$e,$f,$g,$h) = @.s[];
        for ^80 -> $i {
            # We'll mask this below
            my $t1 = [+] $h, @k[$i], @.w[$i],
                         ($g +^ ($e +& ($f +^ $g))),
                         ([+^] ($e Xror (14,18,41)));
            # We'll mask this below
            my $t2 = [+] ([+^] ($a Xror (28,34,39))),
                         ([+^] (($a,$a,$b) >>+&<< ($b,$c,$c)));

            ($a,$b,$c,$d,$e,$f,$g,$h) =
                0xffffffffffffffff +& ($t1 + $t2), $a, $b, $c,
                0xffffffffffffffff +& ($d + $t1), $e, $f, $g;
        }
        # merge the new state
        @.s[] = 0xffffffffffffffff
                X+&
                (@.s[] Z+ (0xffffffffffffffff X+& ($a,$b,$c,$d,$e,$f,$g,$h)));
	return; # This should not be needed per S06/Signatures
    }
}

role Sum::SHA224 does Sum::SHAmix32 does Sum::MDPad {
    my @s_init = 0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939,
                 0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4;
    method init { @s_init }
    method bytes_internal {
        @.s[0..6] X+> (24,16...0)
    }
    method Int_internal {
        # Doesn't work yet:
        # :4294967296[@.s[^7]]
        [+|] (@.s[0..6] Z+< (192,160...0))
    }
    method size { 224 }
}
role Sum::SHA256 does Sum::SHAmix32 does Sum::MDPad {
    my @s_init = 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
                 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19;
    method init { @s_init }
    method bytes_internal {
        @.s[] X+> (24,16...0)
    }
    method Int_internal {
        # Doesn't work yet:
        # :4294967296[@.s[]]
        [+|] (@.s[] Z+< (224,192...0))
    }
    method size { 256 }
}
role Sum::SHA384 does Sum::SHAmix64
     does Sum::MDPad[:blocksize(1024) :lengthtype<uint128_be>] {

    my @s_init = 0xcbbb9d5dc1059ed8, 0x629a292a367cd507,
                 0x9159015a3070dd17, 0x152fecd8f70e5939,
                 0x67332667ffc00b31, 0x8eb44a8768581511,
                 0xdb0c2e0d64f98fa7, 0x47b5481dbefa4fa4;
    method init { @s_init }
    method bytes_internal {
        @.s[0..5] X+> (56,48...0)
    }
    method Int_internal {
        # Doesn't work yet:
        # :18446744073709551616[@.s[^6]]
        [+|] (@.s[0..5] Z+< (320,256...0))
    }
    method size { 384 }
}
role Sum::SHA512 does Sum::SHAmix64
     does Sum::MDPad[:blocksize(1024) :lengthtype<uint128_be>] {

    my @s_init = 0x6a09e667f3bcc908, 0xbb67ae8584caa73b,
                 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
                 0x510e527fade682d1, 0x9b05688c2b3e6c1f,
                 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179;
    method init { @s_init }
    method bytes_internal {
        @.s[] X+> (56,48...0)
    }
    method Int_internal {
        # Doesn't work yet:
        # :18446744073709551616[@.s[]]
        [+|] (@.s[] Z+< (448,384...0))
    }
    method size { 512 }
}

role Sum::SHA2[ :$columns where 224 ] does Sum::SHA224 { }
role Sum::SHA2[ :$columns where 256 ] does Sum::SHA256 { }
role Sum::SHA2[ :$columns where 384 ] does Sum::SHA384 { }
role Sum::SHA2[ :$columns where 512 ] does Sum::SHA512 { }

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2012 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=begin REFERENCES
=item "RFC 6234: US Secure Hash Algorithms (SHA and SHA-based HMAC and HKDF)" (Eastlake, Huawei, Hansen) L<https://tools.ietf.org/html/rfc6234>
=end REFERENCES

=SEE-ALSO C<Sum::(pm3)>

