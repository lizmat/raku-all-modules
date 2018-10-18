=NAME Sum::Recourse - Role to make proxy classes for C digest library loading

=begin SYNOPSIS
=begin code

    use Sum::Recourse;

    # TODO sample code

=end code
=end SYNOPSIS

=begin DESCRIPTION
=end DESCRIPTION

use Sum;

=begin pod

=head2 role Sum::Recourse[ :recourse(:libmhash($x) :librhash($x) :libcrypto($x.lc) :Perl6($class)) ]

The Sum::Recourse role may be mixed in to allow runtime loading of native
C implementations, fallback between native C implementations, and fallback
to pure Perl 6 implementations of a given algorithm.  The C<:recourse>
role parameter takes and ordered list of pairs.  The key of each pair may
be one of "libmhash", "librhash" or "libcrypto" to designate the use
of a C implementation.  Other such tags may be added in the future to
serve other implementations.  The value of each pair contains arguments
to pass to the C<.new> constructor for the corresponding native C class
(e.g. the class C<Sum::libmhash::Sum> in the case of C<"libmhash">.)  This
will usually be the name of that algorithm in said library.

The special key C<"Perl6"> designates a fallback to a pure Perl 6
implementation.  The value of the key should be a fully composed
Perl 6 class which has the necessary marshalling roles mixed in to
behave similarly to classes such as C<Sum::libmash::Sum>.

When a class including this role is instantiated, each of the pairs
from C<:recourse> will be considered in the order in which they
appear.  A check will be made to see if the specified native library
is available, and if it is, an object from that library will be
instantiated and method calls to certain methods will be forwarded
to that object.  If either the library is unavailable, or the object
fails to instantiate, the next pair in the list will be tried until
one succeeds, or until the end of the list is passed, in which case
an C<X::Sum::Recourse> C<Failure> is returned instead.

Most of the ancillary roles from the C<Sum> base interface may be
mixed in alongside Sum::Recourse.  Note that one must still mix
in at least one C<Sum::Marshal::*> role.  Mixing in C<Sum::Partial>
will disable any C<librhash> functionality even if it appears in
C<:recourse>, because C<librhash> lacks the ability to clone contexts.

Note that most C implementations of hashing algorithms are not capable
of generating checksums for messages that do not pack evenly into bytes,
so one should not use C<Sum::Recourse> for this purpose, and rather
should construct a pure Perl 6 implementation from the roles provided
in algorithm-specific modules if this functionality is needed.

=end pod

role Sum::Recourse::Marshal { ... }

role Sum::Recourse[:@recourse!] {

    # Should just be:
    # has $!recourse_imp handles <Int Buf Numeric elems pos size>;
    # but handles will not satisfy role protocols
    has $.recourse_imp;
    has $.recourse_key;
    has Bool $.final = False;

    method Int (|c)      { $!recourse_imp.Int(|c) };
    method Buf (|c)      { $!recourse_imp.Buf(|c) };
    method Blob (|c)     { $!recourse_imp.Blob(|c) };
    method buf8 (|c)     { $!recourse_imp.buf8(|c) };
    method blob8 (|c)    { $!recourse_imp.blob8(|c) };
    method Numeric (|c)  { $!recourse_imp.Numeric(|c) };
    method elems (|c)    { $!recourse_imp.elems(|c) };
    method pos (|c)      { $!recourse_imp.pos(|c) };

    method add (|c) {
        $!recourse_imp.push(|c)
    };

    my sub findalg {
        my $imp;
	my $impkey;

        for @recourse -> $pair ( :key($mod), :value($cap)) {
            given $mod {
                when "libcrypto" {
                    use Sum::libcrypto;
		    next unless $Sum::libcrypto::up;
                    $imp = Sum::libcrypto::Sum.new(|$cap);
		    next unless $imp.defined;
                    $impkey = $mod;
		    last;
                }
                when "librhash" {
                    use Sum::librhash;
                    next if ::?CLASS ~~ Sum::Partial;
		    next unless $Sum::librhash::up;
                    $imp = Sum::librhash::Sum.new(|$cap);
		    next unless $imp.defined;
                    $impkey = $mod;
		    last;
                }
                when "libmhash" {
                    use Sum::libmhash;
		    next unless $Sum::libmhash::up;
                    $imp = Sum::libmhash::Sum.new(|$cap);
		    next unless $imp.defined;
                    $impkey = $mod;
		    last;
                }
                when "Perl6" {
                    $imp = $cap.new;
		    next unless $imp.defined;
                    $impkey = $mod;
		    last;
                }
	    }
	}
	return($impkey, $imp);
    }

    method finalize (|c) {
        # In the Sum::Recourse::Marshal case this should detect $.final
        # In the case of a native implementation, there is an internal sentry.
	given self.push(|c) {
            return $_ unless $_.exception.WHAT ~~ X::Sum::Push::Usage;
        }
# This should work:
#	if ($!recourse_imp ~~ Sum::Recourse::Marshal) {
# ...workaround:
        if ($!recourse_imp.^can("drain")) {
	    given $!recourse_imp.add(|$!recourse_imp.drain) {
                return $_ unless $_.defined;
            }
	}
	$!final = True;
        given $!recourse_imp.finalize {
	    return $_ unless .defined;
	}
	self
    };

    method new (|c) {
	my ($mod, $alg) = findalg;
	return Failure.new(X::Sum::Recourse.new)
	    unless $alg.defined;
	self.bless(:recourse_imp($alg), :recourse_key($mod));
    }

    # TODO: XXX We should not need this, but we do.
    submethod BUILD (:$recourse_imp, :$recourse_key) {
        $!recourse_imp = $recourse_imp;
        $!recourse_key = $recourse_key;
    }

    # These are class methods, so we have to go through all the
    # steps the native code loader would.
    method size (|c)     {
	my ($mod, $alg) = findalg;
	return Failure.new(X::Sum::Recourse.new)
	    unless $alg.defined;

	my $res;
	$res = $alg.size;
	$alg.finalize if defined($alg); # Ensure it gets thrown out promptly
	return $res;
    };

=begin pod

=head3 method recourse(--> Str)

The C<.recourse> method may be called on an instantiated
object of the resulting class.  It will return the textual
key associated with the eventually chosen implementation.

=end pod

    method recourse(--> Str) {
        $!recourse_key;
    }

}

=begin pod

=head2 role Sum::Recourse::Marshal

Most native implementations do not allow messages that do not pack
evenly into bytes.  For example, you cannot take the SHA1 of the 7-bit
message C<0101001> using libcrypto, librhash, or libmhash.  In contrast
the pure Perl 6 implementations do have this ability.

By default, we load native implementations, but if no C implementations
are available on a system, a fallback to pure Perl 6 code is performed.
When this happens it is important that the behavior of the class remains
the same, so we cannot just directly use the Perl 6 implementation,
as it handles addends differently.

The Sum::Recourse::Marshal role may be mixed in to most pure Perl 6
implementations to make it behave exactly like most native implementations
(minus, of course, the speed.)  When it is mixed in, one may directly
C<.push> a single C<blob8> no matter how many elements it has, pushing
a 0-element C<blob8> is a no-op, even if the object is finalized,
and processing for bitwise parameters and raw integers is not provided.

Note that you will not see C<Sum::Recourse::Marshal> listed as a mixed
in role for a class that C<does Sum::Recourse>.  This is because those
classes are wrappers that just drive other class objects underneath.
This allows a lot of extra C<Sum::Marshal::> classes to be mixed into
the wrapper class and still work no matter which back-end is loaded
at runtime.

=end pod

role Sum::Recourse::Marshal {
    has Int $!bsize = self.blocksize div 8;
    has $!left = buf8.new();

    method drain {
        my $res = $!left;
	$!left = buf8.new();
	# Workaround for pre-GLR flattening problem
	[$res];
    }

    multi method push () {
	# No-op.  No need to check $.final
        my $res = Failure.new(X::Sum::Push::Usage.new());
        $res.defined;
        $res;
    }

    # Special error message for attempting bits.
    multi method push (Bool $b, *@) {
       Failure.new(X::Sum::Marshal.new(:recourse<Perl6> :addend<Bool>));
    }

    multi method push (blob8 $addend) {
        # This should be re-implemented when subbuf gets efficient
        # (That is to say, when subbuf(subbuf(*)) collapses properly.)
        my Int $b = 0;
        if $addend.elems {
	    return Failure.new(X::Sum::Final.new) if $.final;
            if $!left.elems {
                if $!left.elems + $addend.elems < $!bsize {
                    $!left = buf8.new($!left.values,$addend.values);
		    $b = $addend.elems;
                }
                else {
		    $b = $!left.elems;
                    $!left = buf8.new($!left.values, $addend[0 ..^ $!bsize - $b]);
		    self.add($!left);
                    $b = $!bsize - $b;
                }
            }
            while $addend.elems - $b >= $!bsize {
		self.add($addend.subbuf($b, $!bsize));
	        $b += $!bsize;
            }
            if $b < $addend.elems {
		$!left = buf8.new($addend[ $b ..^ * ]);
            }
            else {
		$!left = buf8.new()
            }
        }
        my $res = Failure.new(X::Sum::Push::Usage.new());
        $res.defined;
        $res;
    }

}

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2012 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Sum::> C<Sum::libmhash::(pm3)> C<Sum::librhash(pm3)> C<Sum::libcrypto::(pm3)>
