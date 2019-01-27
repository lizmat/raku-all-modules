[![Build Status](https://travis-ci.org/jmaslak/Perl6-IP-Random.svg?branch=master)](https://travis-ci.org/jmaslak/Perl6-IP-Random)

NAME
====

IP::Random - Generate random IP Addresses

SYNOPSIS
========

    use IP::Random;

    my $ipv4 = IP::Random::random_ipv4;
    my @ips  = IP::Random::random_ipv4( count => 100, allow-dupes => False );

DESCRIPTION
===========

This provides a random IP (IPv4 only currently) address, with some extensability to exclude undesired IPv4 addresses (I.E. don't return IP addresses that are in the multicast or RFC1918 ranges).

By default, the IP returned is a valid, publicly routable IP address, but this behavior can be adjusted.

FUNCTIONS
=========

default_ipv4_exclude
--------------------

Returns the default exclude list for IPv4, as a list of CIDR strings.

Additional CIDRs may be added to future versions, but in no case will standard Unicast publicly routable IPs be added. See [named_exclude](named_exclude) to determine what IP ranges will be included in this list.

exclude_ipv4_list($type)
------------------------

When passed a `$type`, such as `'rfc1918'`, will return a list of CIDRs that match that type. See [named_exclude](named_exclude) for the valid types.

random_ipv4( :@exclude, :$count )
---------------------------------

    say random_ipv4;
    say random_ipv4( exclude => ('rfc1112', 'rfc1122') );
    say random_ipv4( exclude => ('default', '24.0.0.0/8') );
    say join( ',',
        random_ipv4( exclude => ('rfc1112', 'rfc1122'), count => 2048 ) );
    say join( ',',
        random_ipv4( count => 2048, allow-dupes => False ) );

This returns a random IPv4 address. If called with no parameters, it will exclude any addresses in the default exclude list.

If called with the exclude optional parameter, which is passed as a list, it will use the exclude types (see [named_exclude](named_exclude) for the types) to exclude from generation. In addition, individual CIDRs may also be passed to exclude those CIDRs. If neither CIDRs or exclude types are passed, it will use the `default` tag to exclude the default excludes. Should you want to exclude nothing, pass an empty list. If you want to exclude something in addition to the default list, you must pass the `default` tag explictly.

The count optional parameter will cause c<random_ipv4> to return a list of random IPv4 addresses (equal to the value of `count`). If `count` is greater than 128, this will be done across multiple CPU cores. Batching in this way will yield significantly higher performance than repeated calls to the `random_ipv4()` routine.

The `allow-dupes` parameter determines whether duplicate IP addresses are allowed to be returned within a batch. The default, `True`, allows duplicate addresses to be randomly picked. Obviously unless there is an extensive exclude list or a very large batch size, the chance of randomly selecting a duplicate is very small. But with extensive excludes and large batch sizes, it is possible to have duplicates selected. If the amount of non-excluded IPv4 space is less than the batch size (the `count` argument) and this parameter is set to `False`, then you will get a list of all possible IP addresses rather than `count` elements returned.

CONSTANTS
=========

named_exclude
-------------

    %excludes = IP::RANDOM::named_exclude

A hash of all the named IP exludes that this `IP::Random` is aware of. The key is the excluded IP address. The value is a list of tags that this module is aware of. For instance, `192.168.0.0/16` would be a key with the values of `( 'rfc1918', 'default' )`.

This list contains:

  * `0.0.0.0/8`

    Tags: default, rfc1122

    "This" Network (RFC1122, Section 3.2.1.3).

  * `10.0.0.0/8`

    Tags: default, rfc1918

    Private-Use Networks (RFC1918).

  * `100.64.0.0/10`

    Shared Address Space (RFC6598)

  * `127.0.0.0/8`

    Tags: default, rfc1122

    Loopback (RFC1122, Section 3.2.1.3)

  * `169.254.0.0/16`

    Link Local (RFC 3927)

  * `172.16.0.0/12`

    Tags: default, rfc1918

    Private-Use Networks (RFC1918)

  * `192.0.0.0/24`

    IETF Protocol Assignments (RFC5736)

  * `192.0.2.0/24`

    TEST-NET-1 (RFC5737)

  * `192.88.99.0/24`

    6-to-4 Anycast (RFC3068)

  * `192.168.0.0/16`

    Tags: default, rfc1918

    Private-Use Networks (RFC1918)

  * `198.18.0.0/15`

    Network Interconnect Device Benchmark Testing (RFC2544)

  * `198.51.100.0/24`

    TEST-NET-2 (RFC5737)

  * `203.0.113.0/24`

    TEST-NET-3 (RFC5737)

  * `224.0.0.0/4`

    Multicast (RFC3171)

  * `240.0.0.0/4`

    Reserved for Future Use (RFC 1112, Section 4)

AUTHOR
======

Joelle Maslak <jmaslak@antelope.net>

CONTRIBUTORS
============

Elizabeth Mattijsen <liz@wenzperl.nl>

EXPRESSING APPRECIATION
=======================

If this module makes your life easier, or helps make you (or your workplace) a ton of money, I always enjoy hearing about it! My response when I hear that someone uses my module is to go back to that module and spend a little time on it if I think there's something to improve - it's motivating when you hear someone appreciates your work!

I don't seek any money for this - I do this work because I enjoy it. That said, should you want to show appreciation financially, few things would make me smile more than knowing that you sent a donation to the Gender Identity Center of Colorado (See [http://giccolorado.org/](http://giccolorado.org/) and donation page at [https://tinyurl.com/giccodonation](https://tinyurl.com/giccodonation)). This organization understands TIMTOWTDI in life and, in line with that understanding, provides life-saving support to the transgender community.

COPYRIGHT AND LICENSE
=====================

Copyright (C) 2018 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

