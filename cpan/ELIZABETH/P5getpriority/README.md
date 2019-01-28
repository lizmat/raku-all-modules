[![Build Status](https://travis-ci.org/lizmat/P5getpriority.svg?branch=master)](https://travis-ci.org/lizmat/P5getpriority)

NAME
====

P5getpriority - Implement Perl 5's getpriority() and associated built-ins

SYNOPSIS
========

    use P5getpriority; # exports getpriority, setpriority, getppid, getpgrp

    say "My parent process priority is &getpriority(0, getppid())";

    say "My process priority is &getpriority(0, $*PID)";

    say "My process group has priority &getpriority(1, getpgrp())";

    say "My user priority is &getpriority(2, $*USER)";

DESCRIPTION
===========

This module tries to mimic the behaviour of the `getpriority` and associated functions of Perl 5 as closely as possible. It exports by default:

    getpgrp getppid getpriority setpgrp setpriority

ORIGINAL PERL 5 DOCUMENTATION
=============================

    getpriority WHICH,WHO
            Returns the current priority for a process, a process group, or a
            user. (See getpriority(2).) Will raise a fatal exception if used
            on a machine that doesn't implement getpriority(2).

    setpriority WHICH,WHO,PRIORITY
            Sets the current priority for a process, a process group, or a
            user. (See setpriority(2).) Raises an exception when used on a
            machine that doesn't implement setpriority(2).

    getpgrp PID
            Returns the current process group for the specified PID. Use a PID
            of 0 to get the current process group for the current process.
            Will raise an exception if used on a machine that doesn't
            implement getpgrp(2). If PID is omitted, returns the process group
            of the current process. Note that the POSIX version of "getpgrp"
            does not accept a PID argument, so only "PID==0" is truly
            portable.

    setpgrp PID,PGRP
            Sets the current process group for the specified PID, 0 for the
            current process. Raises an exception when used on a machine that
            doesn't implement POSIX setpgid(2) or BSD setpgrp(2). If the
            arguments are omitted, it defaults to "0,0". Note that the BSD 4.2
            version of "setpgrp" does not accept any arguments, so only
            "setpgrp(0,0)" is portable. See also "POSIX::setsid()".

    getppid Returns the process id of the parent process.

            Note for Linux users: Between v5.8.1 and v5.16.0 Perl would work
            around non-POSIX thread semantics the minority of Linux systems
            (and Debian GNU/kFreeBSD systems) that used LinuxThreads, this
            emulation has since been removed. See the documentation for $$ for
            details.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getpriority . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

