[![Build Status](https://travis-ci.org/lizmat/User-grent.svg?branch=master)](https://travis-ci.org/lizmat/User-grent)

NAME
====

User::grent - Port of Perl 5's User::grent

SYNOPSIS
========

    use User::grent;
    $gr = getgrgid(0) or die "No group zero";
    if $gr.name eq 'wheel' && $gr.members > 1 {
        print "gid zero name wheel, with other members";
    } 
     
    use User::grent qw(:FIELDS);
    getgrgid(0) or die "No group zero";
    if $gr_name eq 'wheel' && @gr_members > 1 {
        print "gid zero name wheel, with other members";
    } 
     
    $gr = getgr($whoever);

DESCRIPTION
===========

This module's default exports `getgrent`, `getgrgid`, and `getgrnam` functions, replacing them with versions that return `User::grent` objects. This object has methods that return the similarly named structure field name from the C's passwd structure from grp.h; namely name, passwd, gid, and members (not mem). The first three return scalars, the last an array.

You may also import all the structure fields directly into your namespace as regular variables using the :FIELDS import tag. (Note that this still exports the functions.) Access these fields as variables named with a preceding gr_. Thus, `$group_obj.gid` corresponds to `$gr_gid` if you import the fields.

The `getgr` function is a simple front-end that forwards a numeric argumenti to `getgrgid` and the rest to `getgrnam`.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/User-grent . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

