[![Build Status](https://travis-ci.org/lizmat/P5tie.svg?branch=master)](https://travis-ci.org/lizmat/P5tie)

NAME
====

P5tie - Implement Perl 5's tie() built-in

SYNOPSIS
========

    use P5tie; # exports tie(), tied() and untie()

    tie my $s, Tie::AsScalar;
    tie my @a, Tie::AsArray;
    tie my %h, Tie::AsHash;

    $object = tied $s;
    untie $s;

DESCRIPTION
===========

This module tries to mimic the behaviour of `tie` and related functions of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    tie VARIABLE,CLASSNAME,LIST
            This function binds a variable to a package class that will
            provide the implementation for the variable. VARIABLE is the name
            of the variable to be enchanted. CLASSNAME is the name of a class
            implementing objects of correct type. Any additional arguments are
            passed to the appropriate constructor method of the class (meaning
            "TIESCALAR", "TIEHANDLE", "TIEARRAY", or "TIEHASH"). Typically
            these are arguments such as might be passed to the "dbm_open()"
            function of C. The object returned by the constructor is also
            returned by the "tie" function, which would be useful if you want
            to access other methods in CLASSNAME.

            Note that functions such as "keys" and "values" may return huge
            lists when used on large objects, like DBM files. You may prefer
            to use the "each" function to iterate over such. Example:

                # print out history file offsets
                use NDBM_File;
                tie(%HIST, 'NDBM_File', '/usr/lib/news/history', 1, 0);
                while (($key,$val) = each %HIST) {
                    print $key, ' = ', unpack('L',$val), "\n";
                }
                untie(%HIST);

            A class implementing a hash should have the following methods:

                TIEHASH classname, LIST
                FETCH this, key
                STORE this, key, value
                DELETE this, key
                CLEAR this
                EXISTS this, key
                FIRSTKEY this
                NEXTKEY this, lastkey
                SCALAR this
                DESTROY this
                UNTIE this

            A class implementing an ordinary array should have the following
            methods:

                TIEARRAY classname, LIST
                FETCH this, key
                STORE this, key, value
                FETCHSIZE this
                STORESIZE this, count
                CLEAR this
                PUSH this, LIST
                POP this
                SHIFT this
                UNSHIFT this, LIST
                SPLICE this, offset, length, LIST
                EXTEND this, count
                DELETE this, key
                EXISTS this, key
                DESTROY this
                UNTIE this

            A class implementing a filehandle should have the following
            methods:

                TIEHANDLE classname, LIST
                READ this, scalar, length, offset
                READLINE this
                GETC this
                WRITE this, scalar, length, offset
                PRINT this, LIST
                PRINTF this, format, LIST
                BINMODE this
                EOF this
                FILENO this
                SEEK this, position, whence
                TELL this
                OPEN this, mode, LIST
                CLOSE this
                DESTROY this
                UNTIE this

            A class implementing a scalar should have the following methods:

                TIESCALAR classname, LIST
                FETCH this,
                STORE this, value
                DESTROY this
                UNTIE this

            Not all methods indicated above need be implemented. See perltie,
            Tie::Hash, Tie::Array, Tie::Scalar, and Tie::Handle.

            Unlike "dbmopen", the "tie" function will not "use" or "require" a
            module for you; you need to do that explicitly yourself. See
            DB_File or the Config module for interesting "tie"
            implementations.

            For further details see perltie, "tied VARIABLE".

    tied VARIABLE
            Returns a reference to the object underlying VARIABLE (the same
            value that was originally returned by the "tie" call that bound
            the variable to a package.) Returns the undefined value if
            VARIABLE isn't tied to a package.

    untie VARIABLE
            Breaks the binding between a variable and a package. (See tie.)
            Has no effect if the variable is not tied.

PORTING CAVEATS
===============

Please note that there are usually better ways attaching special functionality to arrays, hashes and scalars in Perl 6 than using `tie`. Please see the documentation on [Custom Types](https://docs.perl6.org/language/subscripts#Custom_types) for more information to handling the needs that Perl 5's `tie` fulfills in a more efficient way in Perl 6.

Subs versus Methods
-------------------

In Rakudo Perl 6, the special methods of the tieing class, can be implemented as Perl 6 `method`s, or they can be implemented as `our sub`s, both are perfectly acceptable. They can even be mixed, if necessary. But note that if you're depending on subclassing, that you must change the `package` to a `class` to make things work.

Untieing
--------

Because Rakudo Perl 6 does not have the concept of magic that can be added or removed, it is **not** possible to `untie` a variable. Note that the associated `UNTIE` sub/method **will** be called, so that any resources can be freed.

Potentially it would be possible to actually have any subsequent accesses to the tied variable throw an exception: perhaps it will at some point.

Scalar variable tying versus Proxy
----------------------------------

Because tying a scalar in Rakudo Perl 6 **must** be implemented using a `Proxy`, and it is currently not possible to mix in any additional behaviour into a `Proxy`, it is alas impossible to implement `UNTIE` and `DESTROY` for tied scalars at this point in time. Please note that `UNTIE` and `DESTROY` **are** supported for tied arrays and hashes.

Tieing a file handle
--------------------

Tieing a file handle is not yet implemented at this time. Mainly because I don't grok yet how to do that. As usual, patches and Pull Requests are welcome!

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5tie . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

