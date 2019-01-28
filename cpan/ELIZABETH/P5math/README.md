[![Build Status](https://travis-ci.org/lizmat/P5math.svg?branch=master)](https://travis-ci.org/lizmat/P5math)

NAME
====

P5math - Port of Perl 5's math built-ins to Perl 6

SYNOPSIS
========

    use P5math; # exports abs cos crypt exp int log rand sin sqrt

DESCRIPTION
===========

This module tries to mimic the behaviour of the `abs`, `cos`, `crypt`, `exp`, `int`, `log`, `rand`, `sin` and `sqrt` functions of Perl 5 as closely as possible.

PORTING CAVEATS
===============

As of this writing (2018.05), it is **not** possible to actually use `int` in your code because of code generation issue caused by the fact that `int` is a built-in native type in Perl 6.

Other functions may not be callable without actually specifying (no) parameters.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    abs VALUE
    abs     Returns the absolute value of its argument. If VALUE is omitted,
            uses $_.

    cos EXPR
    cos     Returns the cosine of EXPR (expressed in radians). If EXPR is
            omitted, takes the cosine of $_.

            For the inverse cosine operation, you may use the
            "Math::Trig::acos()" function, or use this relation:

                sub acos { atan2( sqrt(1 - $_[0] * $_[0]), $_[0] ) }

    crypt PLAINTEXT,SALT
            Creates a digest string exactly like the crypt(3) function in the
            C library (assuming that you actually have a version there that
            has not been extirpated as a potential munition).

            crypt() is a one-way hash function. The PLAINTEXT and SALT are
            turned into a short string, called a digest, which is returned.
            The same PLAINTEXT and SALT will always return the same string,
            but there is no (known) way to get the original PLAINTEXT from the
            hash. Small changes in the PLAINTEXT or SALT will result in large
            changes in the digest.

            There is no decrypt function. This function isn't all that useful
            for cryptography (for that, look for Crypt modules on your nearby
            CPAN mirror) and the name "crypt" is a bit of a misnomer. Instead
            it is primarily used to check if two pieces of text are the same
            without having to transmit or store the text itself. An example is
            checking if a correct password is given. The digest of the
            password is stored, not the password itself. The user types in a
            password that is crypt()'d with the same salt as the stored
            digest. If the two digests match, the password is correct.

            When verifying an existing digest string you should use the digest
            as the salt (like "crypt($plain, $digest) eq $digest"). The SALT
            used to create the digest is visible as part of the digest. This
            ensures crypt() will hash the new string with the same salt as the
            digest. This allows your code to work with the standard crypt and
            with more exotic implementations. In other words, assume nothing
            about the returned string itself nor about how many bytes of SALT
            may matter.

            Traditionally the result is a string of 13 bytes: two first bytes
            of the salt, followed by 11 bytes from the set "[./0-9A-Za-z]",
            and only the first eight bytes of PLAINTEXT mattered. But
            alternative hashing schemes (like MD5), higher level security
            schemes (like C2), and implementations on non-Unix platforms may
            produce different strings.

            When choosing a new salt create a random two character string
            whose characters come from the set "[./0-9A-Za-z]" (like "join '',
            ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64]"). This set
            of characters is just a recommendation; the characters allowed in
            the salt depend solely on your system's crypt library, and Perl
            can't restrict what salts "crypt()" accepts.

            Here's an example that makes sure that whoever runs this program
            knows their password:

                $pwd = (getpwuid($<))[1];

                system "stty -echo";
                print "Password: ";
                chomp($word = <STDIN>);
                print "\n";
                system "stty echo";

                if (crypt($word, $pwd) ne $pwd) {
                    die "Sorry...\n";
                } else {
                    print "ok\n";
                }

            Of course, typing in your own password to whoever asks you for it
            is unwise.

            The crypt function is unsuitable for hashing large quantities of
            data, not least of all because you can't get the information back.
            Look at the Digest module for more robust algorithms.

            If using crypt() on a Unicode string (which potentially has
            characters with codepoints above 255), Perl tries to make sense of
            the situation by trying to downgrade (a copy of) the string back
            to an eight-bit byte string before calling crypt() (on that copy).
            If that works, good. If not, crypt() dies with "Wide character in
            crypt".

            Portability issues: "crypt" in perlport.

    exp EXPR
    exp     Returns me (the natural logarithm base) to the power of EXPR. If
            EXPR is omitted, gives "exp($_)".

    int EXPR
    int     Returns the integer portion of EXPR. If EXPR is omitted, uses $_.
            You should not use this function for rounding: one because it
            truncates towards 0, and two because machine representations of
            floating-point numbers can sometimes produce counterintuitive
            results. For example, "int(-6.725/0.025)" produces -268 rather
            than the correct -269; that's because it's really more like
            -268.99999999999994315658 instead. Usually, the "sprintf",
            "printf", or the "POSIX::floor" and "POSIX::ceil" functions will
            serve you better than will int().

    log EXPR
    log     Returns the natural logarithm (base e) of EXPR. If EXPR is
            omitted, returns the log of $_. To get the log of another base,
            use basic algebra: The base-N log of a number is equal to the
            natural log of that number divided by the natural log of N. For
            example:

                sub log10 {
                    my $n = shift;
                    return log($n)/log(10);
                }

            See also "exp" for the inverse operation.

    rand EXPR
    rand    Returns a random fractional number greater than or equal to 0 and
            less than the value of EXPR. (EXPR should be positive.) If EXPR is
            omitted, the value 1 is used. Currently EXPR with the value 0 is
            also special-cased as 1 (this was undocumented before Perl 5.8.0
            and is subject to change in future versions of Perl).
            Automatically calls "srand" unless "srand" has already been
            called. See also "srand".

            Apply "int()" to the value returned by "rand()" if you want random
            integers instead of random fractional numbers. For example,

                int(rand(10))

            returns a random integer between 0 and 9, inclusive.

            (Note: If your rand function consistently returns numbers that are
            too large or too small, then your version of Perl was probably
            compiled with the wrong number of RANDBITS.)

            "rand()" is not cryptographically secure. You should not rely on
            it in security-sensitive situations. As of this writing, a number
            of third-party CPAN modules offer random number generators
            intended by their authors to be cryptographically secure,
            including: Data::Entropy, Crypt::Random, Math::Random::Secure, and
            Math::TrulyRandom.

    sin EXPR
    sin     Returns the sine of EXPR (expressed in radians). If EXPR is
            omitted, returns sine of $_.

            For the inverse sine operation, you may use the "Math::Trig::asin"
            function, or use this relation:

                sub asin { atan2($_[0], sqrt(1 - $_[0] * $_[0])) }

    sqrt EXPR
    sqrt    Return the positive square root of EXPR. If EXPR is omitted, uses
            $_. Works only for non-negative operands unless you've loaded the
            "Math::Complex" module.

                use Math::Complex;
                print sqrt(-4);    # prints 2i

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5math . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

