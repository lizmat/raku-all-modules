[![Build Status](https://travis-ci.org/lizmat/Net-protoent.svg?branch=master)](https://travis-ci.org/lizmat/Net-protoent)

NAME
====

Net::protoent - Port of Perl 5's Net::protoent

SYNOPSIS
========

    use Net::protoent;
    my $p = getprotobyname('tcp') || die "no proto";
    printf "proto for %s is %d, aliases are %s\n",
       $p.name, $p.proto, "$p.aliases()";
     
    use Net::protoent qw(:FIELDS);
    getprotobyname('tcp')         || die "no proto";
    print "proto for $p_name is $p_proto, aliases are @p_aliases\n";

DESCRIPTION
===========

This module's exports `getprotobyname`, `getprotobynumber`, and `getprotoent` functions that return `Netr::protoent` objects. This object has methods that return the similarly named structure field name from the C's protoent structure from netdb.h, stripped of their leading "p_" parts, namely name, aliases, and proto.

You may also import all the structure fields directly into your namespace as regular variables using the :FIELDS import tag. Access these fields as variables named with a preceding p_ in front their method names. Thus, $proto_obj.name corresponds to $p_name if you import the fields.

The `getproto` function is a simple front-end that forwards a numeric argument to `getprotobynumber` and the rest to `getprotobyname`.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Net-protoent . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

