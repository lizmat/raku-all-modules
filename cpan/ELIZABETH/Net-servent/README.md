[![Build Status](https://travis-ci.org/lizmat/Net-servent.svg?branch=master)](https://travis-ci.org/lizmat/Net-servent)

NAME
====

Net::servent - Port of Perl 5's Net::servent

SYNOPSIS
========

    use Net::servent;
    $s = getservbyname('ftp') || die "no service";
    printf "port for %s is %s, aliases are %s\n",
       $s.name, $s.port, "@_aliases[]";
     
    use Net::servent qw(:FIELDS);
    getservbyname('ftp') || die "no service";
    print "port for $s_name is $s_port, aliases are @s_aliases[]\n";

DESCRIPTION
===========

This module's exports `getservbyname`, `getservbyportd`, and `getservent` functions that return `Net::servent` objects. This object has methods that return the similarly named structure field name from the C's servent structure from servdb.h, stripped of their leading "s_" parts, namely name, aliases, port and proto.

You may also import all the structure fields directly into your namespace as regular variables using the :FIELDS import tag. Access these fields as variables named with a preceding s_ in front their method names. Thus, $serv_obj.name corresponds to $s_name if you import the fields.

The `getserv` function is a simple front-end that forwards a numeric argument to `getservbyport` and the rest to `getservbyname`.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/serv-servent . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

