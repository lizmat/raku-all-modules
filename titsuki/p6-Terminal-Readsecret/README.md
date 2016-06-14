[![Build Status](https://travis-ci.org/titsuki/p6-Terminal-Readsecret.svg?branch=master)](https://travis-ci.org/titsuki/p6-Terminal-Readsecret)

NAME
====

Terminal::Readsecret - A perl6 binding of readsecret ( https://github.com/dmeranda/readsecret ) for reading secrets or passwords from a command line secretly (not being displayed)

SYNOPSIS
========

EXAMPLE1
--------

    use Terminal::Readsecret;
    my $password = getsecret("password:" );
    say "your password is: " ~ $password;

EXAMPLE2
--------

    use Terminal::Readsecret;
    my timespec $timeout .= new(tv_sec => 5, tv_nsec => 0); # set timeout to 5 sec
    my $password = getsecret("password:", $timeout);
    say "your password is: " ~ $password;

DESCRIPTION
===========

Terminal::Readsecret is a perl6 binding of readsecret ( [https://github.com/dmeranda/readsecret](https://github.com/dmeranda/readsecret) ). Readsecret is a simple self-contained C (or C++) library intended to be used on Unix and Unix-like operating systems that need to read a password or other textual secret typed in by the user while in a text-mode environment, such as from a console or shell.

METHODS
-------

### getsecret

    proto getsecret(Str:D, |) returns Str
    multi sub getsecret(Str:D) returns Str
    multi sub getsecret(Str:D, timespec) returns Str

Reads secrets or passwords from a command line and returns its input.

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

Readsecret by Deron Meranda is licensed under Public Domain ( [http://creativecommons.org/publicdomain/zero/1.0/](http://creativecommons.org/publicdomain/zero/1.0/) ).

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

SEE ALSO
========

  * readsecret [https://github.com/dmeranda/readsecret](https://github.com/dmeranda/readsecret)
