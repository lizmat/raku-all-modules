LibUUID
=======

[![Build Status](https://travis-ci.org/CurtTilmes/perl6-libuuid.svg)](https://travis-ci.org/CurtTilmes/perl6-libuuid)

Perl 6 bindings for [libuuid](https://libuuid.sourceforge.io/).

This library creates Universally Unique IDentifiers (UUID).

The uuid will be generated based on high-quality randomness from
/dev/urandom, if available.  If it is not available, then it will use
an alternative algorithm which uses the current time, the local
ethernet MAC address (if available), and random data generated using a
pseudo-random generator.

Installation
============

This module depends on [libuuid](https://libuuid.sourceforge.io/), so
it must be installed first.

For Linux ubuntu, try `sudo apt-get install uuid-dev`.

Then install this module with `zef install LibUUID`.

Usage
=====

    use LibUUID;

    my $uuid = UUID.new;  # Create a new UUID

    $uuid = UUID.new($myblob); # From existing blob of 16 bytes

    $uuid = UUID.new('39ed750e-a1bf-4792-81d6-e098f01152d3'); # From Str

    say ~$uuid; # Stringify to hex digits with dashes

    say $uuid.Blob; # Blobify to Blob of 16 bytes

See Also
========

[UUID](https://github.com/retupmoca/P6-UUID) is a Perl 6 native UUID
generator which generates UUIDs from Perl's internal random number
generator.

On Linux machines, you can get UUIDs straight from the kernel:

    cat /proc/sys/kernel/random/uuid
