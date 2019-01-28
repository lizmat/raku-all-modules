[![Build Status](https://travis-ci.org/lizmat/P5__DATA__.svg?branch=master)](https://travis-ci.org/lizmat/P5__DATA__)

NAME
====

P5__DATA__ - Implement Perl 5's __DATA__ and related functionality

SYNOPSIS
========

    use P5__DATA__; # exports DATA and a slang

DESCRIPTION
===========

This module tries to mimic the behaviour of `__DATA__` and `__END__` and the associated `DATA` file handle of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    Text after __DATA__ may be read via the filehandle "PACKNAME::DATA", where
    "PACKNAME" is the package that was current when the __DATA__ token was
    encountered. The filehandle is left open pointing to the line after
    __DATA__. The program should "close DATA" when it is done reading from it.
    (Leaving it open leaks filehandles if the module is reloaded for any
    reason, so it's a safer practice to close it.) For compatibility with
    older scripts written before __DATA__ was introduced, __END__ behaves like
    __DATA__ in the top level script (but not in files loaded with "require"
    or "do") and leaves the remaining contents of the file accessible via
    "main::DATA".

PORTING CAVEATS
===============

__END__ functions in the same was as __DATA__.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5__DATA__ . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

