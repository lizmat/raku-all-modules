[![Build Status](https://travis-ci.org/skaji/App-P6Ghq.svg?branch=master)](https://travis-ci.org/skaji/App-P6Ghq)

NAME
====

App::P6Ghq - get Perl6 module's repository by ghq

SYNOPSIS
========

    ❯ p6-ghq App::Mi6
    ==> Searching App::Mi6 by zef...
    ==> Cloning git://github.com/skaji/mi6.git by ghq...
         clone git://github.com/skaji/mi6.git -> /Users/skaji/src/github.com/skaji/mi6
           git clone git://github.com/skaji/mi6.git /Users/skaji/src/github.com/skaji/mi6
    Cloning into '/Users/skaji/src/github.com/skaji/mi6'...
    remote: Counting objects: 497, done.
    remote: Total 497 (delta 0), reused 0 (delta 0), pack-reused 497
    Receiving objects: 100% (497/497), 73.34 KiB | 387.00 KiB/s, done.
    Resolving deltas: 100% (191/191), done.

DESCRIPTION
===========

App::P6Ghq gets Perl6 module's repository by [ghq](https://github.com/motemen/ghq).

SEE ALSO
========

https://metacpan.org/pod/App::CPANGhq

AUTHOR
======

Shoichi Kaji <skaji@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
