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

=head2 role Sum::Recourse[ :recourse(:libmhash($x) :librhash($x) :libcrypto($x.lc) :Perl6($class))]

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

role Sum::Recourse[:@recourse!] {

    # Should just be:
    # has $!recourse_imp handles <add finalize Buf Numeric elems pos size>;
    # but handles will not satisfy role protocols
    has $.recourse_imp;
    has $.recourse_key;

    method add (|c)      { $!recourse_imp.add(|c) };
    method Buf (|c)      { $!recourse_imp.Buf(|c) };
    method Blob (|c)     { $!recourse_imp.Blob(|c) };
    method buf8 (|c)     { $!recourse_imp.buf8(|c) };
    method blob8 (|c)    { $!recourse_imp.blob8(|c) };
    method Numeric (|c)  { $!recourse_imp.Numeric(|c) };
    method elems (|c)    { $!recourse_imp.elems(|c) };
    method pos (|c)      { $!recourse_imp.pos(|c) };

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
        self.push(|c);
        $!recourse_imp.finalize
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

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2012 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Sum::> C<Sum::libmhash::(pm3)> C<Sum::librhash(pm3)> C<Sum::libcrypto::(pm3)>
