=NAME Sum::GOST - implementation of GOST digest family for Sum::

=begin SYNOPSIS
=begin code
    use Sum::GOST;

    class mySum does Sum::GOST[:sbox<CryptoPro>] does Sum::Marshal::Raw { }
    my mySum $a .= new();
    $a.finalize("abc".encode('ascii')).fmt.say;
       # b285056dbf18d7392d7677369524dd14747459ed8143997e163b2986f92fd42c

    # use default "test parameters" S-box
    class mySum1 does Sum::GOST does Sum::Marshal::Raw { }
    my mySum1 $b .= new();
    $b.finalize("message digest".encode('ascii')).fmt.say;
       # ad4434ecb18f2c99b60cbe59ec3d2469582b65273f48de72db2fde16a4889a4d

=end code
=end SYNOPSIS

# This is a bit of a hack.  We want the test suite to be able to try to
# run the code in the synopsis.  When pod is more functional maybe this
# will become more maintainable.  In the meantime, if you edit anything
# above, take care to adjust the sections here.

$Sum::GOST::Doc::synopsis = $=pod[1].contents[0].contents.Str;

=begin DESCRIPTION
    Using C<Sum::GOST> defines roles for generating types of C<Sum> that
    calculate hashes according to the GOST algorithm.  Different revisions
    of the algorithm may be selected via the C<:sbox> role parameter.
    Note that currently only the "R 34.11-94" implementation is available.

    GOST sums can be computationally intense.  They also require a small
    but significant memory profile while not finalized, so care must be
    taken when huge numbers of concurrent instances are used.

    NOTE: This implementation is unaudited and is for experimental
    use only.  When audits will be performed will depend on the maturation
    of individual Perl6 implementations, and should be considered
    on an implementation-by-implementation basis.

=end DESCRIPTION

use Sum;
use Sum::Recourse;

=begin pod

=head1 ROLES

=head2 role Sum::GOST[:sbox? :recourse = True]

    The C<Sum::GOST> parametric roles are used to create a type of C<Sum>
    that calculates a GOST message digest.  The earlier, obseleted GOST
    version is the default.  Using the C<:sbox> role parameter one may
    calculate the "Crypto Pro" version of the GOST hash.  This uses a
    different parameter tuned for "production use."

    There currently is no pure Perl 6 implementation for this hash
    algorithm, so the only recourses are C library bindings.

    When C<:recourse> is defined (the default, and currently, the only
    choice), behavior is to use C<librhash>.  C<libmhash> is not used,
    even when the C<:sbox> parameter is unset, as the C<libmhash>
    implementation of GOST is broken as of this writing.

    The default precedence of C libraries may be adjusted from time
    to time to prefer the best performing implementation.  To set your
    own preferences, build your own class mixing C<Sum::Recourse>.

=end pod

role Sum::GOST[ :$sbox where { $_ eq "test parameters" }
                  = "test parameters",
                :$recourse where { $_ == True }
                  = True ] does Sum does Sum::Recourse[:recourse[:librhash<GOST>]] { }  # add libmhash<GOST>, with tests, if it ever starts working.

role Sum::GOST[ :$sbox where { $_ eq "CryptoPro" }
                  = "test parameters",
                :$recourse where { $_ == True }
                  = True ] does Sum does Sum::Recourse[:recourse[:librhash<GOST-CRYPTOPRO>]] { }

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2012 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=begin REFERENCES

=item "RFC 5831: GOST R 34.11-94: Hash Function Algorithm" (Cryptocom, Ltd.) L<http://tools.ietf.org/html/rfc5831>
=item "RFC 6986: GOST R 34.11-2012: Hash Function" (Cryptocom, Ltd.) L<http://http://tools.ietf.org/html/rfc6986>

=end REFERENCES

=SEE-ALSO C<Sum::(pm3)>

