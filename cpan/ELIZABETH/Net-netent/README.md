[![Build Status](https://travis-ci.org/lizmat/Net-netent.svg?branch=master)](https://travis-ci.org/lizmat/Net-netent)

NAME
====

Net::netent - Port of Perl 5's Net::netent

SYNOPSIS
========

    use Net::netent;

    my $n = getnetbyname("loopback")       or die "bad net";
    printf "%s is %08X\n", $n.name, $n.net;

    use Net::netent qw(:FIELDS);
    getnetbyname("loopback")               or die "bad net";
    printf "%s is %08X\n", $n_name, $n_net;

DESCRIPTION
===========

This module's exports `getnetbyname`, `getnetbyaddrd`, and `getnetent` functions that return `Netr::netent` objects. This object has methods that return the similarly named structure field name from the C's netent structure from netdb.h, stripped of their leading "n_" parts, namely name, aliases, addrtype and net.

You may also import all the structure fields directly into your namespace as regular variables using the :FIELDS import tag. Access these fields as variables named with a preceding n_ in front their method names. Thus, $net_obj.name corresponds to $n_name if you import the fields.

The `getnet` function is a simple front-end that forwards a numeric argument to `getnetbyaddr` and the rest to `getnetbyname`.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Net-netent . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

