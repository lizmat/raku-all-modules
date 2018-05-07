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

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getpriority . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

