=NAME Sum::SipHash - SipHash role for Sum::

=begin SYNOPSIS
=begin code
    use Sum::SipHash;

    class SipHash_2_4 does Sum::SipHash does Sum::Marshal::Raw { }
    my SipHash_2_4 $a .= new(:key(0x000102030405060708090a0b0c0d0e0f));
    $a.finalize(0..0xe).base(16).say; # A129CA6149BE45E5

=end code
=end SYNOPSIS

# TODO: figure out how to attach this to a WHY which is accessible
# (or figure out how to get to another module's $=pod)
$Sum::SipHash::Doc::synopsis = $=pod[1].contents[0].contents.Str;

=begin DESCRIPTION
    C<Sum::SipHash> defines a parameterized role for generating types
    of C<Sum> that calculate variants of SipHash.  SipHash is a hash
    code which was developed to be efficient enough for general use,
    including use in live data structures, while remaining resistant
    to denial-of-service attacks that rely on finding hash collisions.
    It is not intended for use in strong cryptography.
=end DESCRIPTION

=begin pod

=head1 ROLES

=head2 role Sum::SipHash [ :$c = 2, :$d = 4, :$defkey = 0 ] does Sum

    The C<Sum::SipHash> parametric role is used to create a type of C<Sum>
    that calculates a variant of SipHash.

    The C<:defkey> parameter provides an integer key value that will be
    applied to all instances which do not specify their own.  See the
    documentation below for C<.new>'s C<:key> parameter.

    The C<:c> parameter specifies the number of SipRounds performed
    during a "compression" (which happens about once per eight bytes of
    data) and the C<:d> parameter specifies the number of rounds used
    when the C<Sum> is C<.finalize>d.  Together they determine the
    strength of the hash: increasing either parameter yields more
    resistance to collision analysis, but will increase the computational
    cost.  By default, the role calculates SipHash-2-4, which is the
    standard's notation for C<:c(2) :d(4)>.  This is the suggested
    variant for general use.  When extra collision resistance is desired,
    the specification suggests using the "conservative" SipHash-4-8.

    The number of addends may be determined on the fly, and in this
    implementation, finalization is performed without altering internal
    state, so the C<Sum::Partial> role may be mixed.

=end pod

use Sum;

role Sum::SipHash [ Int :$c = 2, Int :$d = 4, Int :$defkey = 0 ] does Sum {

    my blob8 $keyfrob = "somepseudorandomlygeneratedbytes".encode("ascii");

    has Int $!k0   = 0;
    has Int $!k1   = 0;
    has Int $!v0   = 0;
    has Int $!v1   = 0;
    has Int $!v2   = 0;
    has Int $!v3   = 0;
    has Int $!b    = 0;
    has Int $!left = 0;

=begin pod

=head2 METHODS

=head3 method new(:$key?)

    There is an internal well-known seed built into the SipHash
    specification.  The least significant 128 bits of an integer key
    may be used to alter this seed.

    The constructor allows an individual instance to use its own seed
    by providing a C<:key> argument.  An individual class may supply
    a default key which will be used if the C<:key> argument is omitted
    from the constructor.

    The class-provided key will not be used at all if C<:key> is provided.
    As such, two instances of different C<Sum::SipHash> classes which
    differ only in the class's C<:defkey> will always generate the same
    results if the instances were constructed using the same C<:key> argument.

    Explicitly specifying C<:key(0)> always uses the naked well-known seed,
    which is more likely to have been analyzed by potential adversaries.
    Classes which do not provide a default key (or which explicity set
    C<:defkey(0)>) will create instances that use the naked well-known seed
    if C<:key> is not provided to the constructor.

    The process of modifying the seed is resilient against accidentally
    zeroing the seed, so any value other than zero may be safely chosen.

=end pod

    # There is not actually a custom constructor, it is just docced as-if

    submethod BUILD (:$key is copy = $defkey) {
        $key = Int($key);

        # The K constants must be a little-endian encoding of the key.
        $!k1 = :256[ 255 X+& ($key X+> (0,8...^64))    ];
        $!k0 = :256[ 255 X+& ($key X+> (64,72...^128)) ];

        # The internal key also uses a little-endian representation.
        $!v0 = $!k0 +^ :256[$keyfrob[^8]];
        $!v1 = $!k1 +^ :256[$keyfrob[8..^16]];
        $!v2 = $!k0 +^ :256[$keyfrob[16..^24]];
        $!v3 = $!k1 +^ :256[$keyfrob[24..^32]];
    }

#    has Int $.size = 64; should work, but doesn't during multirole mixin
    method size ( --> int ) { 64 };

    my sub rol (Int $v is rw, int $count --> Nil) {
        my $tmp = (($v +& (0xffffffffffffffff +> $count)) +< $count);
        $tmp +|= (($v +& 0xffffffffffffffff) +> (64 - $count));
	$v = $tmp;
	return;
    }

    my sub SipRound (Int $v0 is rw, Int $v1 is rw,
                     Int $v2 is rw, Int $v3 is rw --> Nil) {
        $v0 += $v1;    $v2 += $v3;
        rol($v1, 13);  rol($v3, 16);
        $v1 +^= $v0;   $v3 +^= $v2;
        rol($v0, 32);

        $v2 += $v1;    $v0 += $v3;
        rol($v1, 17);  rol($v3, 21);
        $v1 +^= $v2;   $v3 +^= $v0;
        rol($v2, 32);

	# These should not be needed with proper uint64 support
	$v0 +&= 0xffffffffffffffff;
	$v1 +&= 0xffffffffffffffff;
	$v3 +&= 0xffffffffffffffff;
	return;
    }

    my sub compression (Int $w, Int $v0 is rw, Int $v1 is rw,
                                Int $v2 is rw, Int $v3 is rw --> Nil) {
        $v3 +^= $w;
        SipRound($v0, $v1, $v2, $v3) for ^$c;
        $v0 +^= $w;
	return;
    }

=begin pod

=head3 multi method add(uint8(Any) *@addends)

    The C<.add> method expects a list of single byte addends.  It is
    generally not used directly by applications.

    A C<Sum::Marshal::*> role must be mixed into the class, and some
    such roles may also be used to properly process wider or narrower
    addends as appropriate to the application through the C<.push>
    method.

    NOTE: Currently no sized native type support is available, so rather than
    being coerced to C<uint8>, addends are coerced to C<Int> and 8 lsb are
    used.  This behavior should be stable, barring any surprises in the
    semantics of C<uint8>'s coercion operation.  Any future cut-through
    optimizations for wider low-level types will be done behind the scenes
    and presented as C<Sum::Marshal> mixins.

=end pod

    method add (*@addends) {
        for (@addends) -> $a is copy {
            $a = Int($a) +& 255;

            my $pos = $!b;
            $!b++;

            $!left +|= ($a +< (8 * ($pos % 8)));
            unless ($!b % 8) {
                compression($!left, $!v0, $!v1, $!v2, $!v3);
                $!left = 0;
	    }
        }
        return;
    };

    method pos () { $!b };

    method elems () { $!b };

    method finalize(*@addends) {
        self.push(@addends);
	self.Int;
	self
    }

    method Numeric () {
        my ($v0, $v1, $v2, $v3) = $!v0, $!v1, $!v2, $!v3;

        compression($!left +| (($!b +& 255) +< 56),$v0,$v1,$v2,$v3);

        $v2 +^= 0xff;

        SipRound($v0, $v1, $v2, $v3) for ^$d;

        [+^] $v0, $v1, $v2, $v3
    }
    method Int () { self.Numeric }

    # Should not need the $self: here.  RT#120919
    method !dice ($self:) { $self.Int X+> (56,48...0) }

    method buf8 () { buf8.new(self!dice); }
    method Buf () { self.buf8 }

    method blob8 () { blob8.new(self!dice); }
    method Blob () { self.blob8 }
}

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2012 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=begin REFERENCES
=item "SipHash: a fast short-input PRF" Aumasson/Bernstein NAGRA document
    ID b9a943a805fbfc6fde808af9fc0ecdfa
=end REFERENCES

=SEE-ALSO C<Sum::(pm3)>
