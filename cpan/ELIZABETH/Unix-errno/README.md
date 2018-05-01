[![Build Status](https://travis-ci.org/lizmat/Unix-errno.svg?branch=master)](https://travis-ci.org/lizmat/Unix-errno)

NAME
====

Unix::errno - Provide transparent access to errno

SYNOPSIS
========

    use Unix::errno;  # exports errno, set_errno

    set_errno(2);

    say errno;              # No such file or directory (errno = 2)
    say "failed: {errno}";  # failed: No such file or directory
    say +errno;             # 2

DESCRIPTION
===========

This module provides access to the `errno` variable that is available on all Unix-like systems. Please note that in a threaded environment such as Perl 6 is, the value of `errno` is even more volatile than it has been already. For now, this issue is ignored.

CAVEATS
=======

Since setting of any "extern" variables is not supported yet by `NativeCall`, the setting of `errno` is faked. If `set_errno` is called, it will set the value only in a shadow copy. That value will be returned As long as the underlying "real" errno doesn't change (at which point that value will be returned.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Unix-errno . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

