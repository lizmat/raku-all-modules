NAME
====

Hashids — generate short and reversable hashes from numbers.

[![Build Status](https://travis-ci.org/kalkin/perl6-hashids.svg?branch=master)](https://travis-ci.org/kalkin/perl6-hashids)

SYNOPSIS
========

```perl6
    use Hashids;
    my $hashids = Hashids.new('this is my salt');

    # encrypt a single number
    my $hash = $hashids.encode(123);         # 'YDx'
    my $number = $hashids.decode('Ydx');     # 123

    # or a list
    $hash = $hashids.encode(1, 2, 3);        # 'laHquq'
    my @numbers = $hashids.decode('laHquq'); # (1, 2, 3)
```

DESCRIPTION
===========

Hashids is designed for use in URL shortening, tracking stuff, validating accounts or making pages private (through abstraction.) Instead of showing items as `1`, `2`, or `3`, you could show them as `b9iLXiAa`, `EATedTBy`, and `Aaco9cy5`. Hashes depend on your salt value.

This is a port of the Hashids JavaScript library for Perl 6.

**IMPORTANT**: This implementation follows the v1.0.0 API release of hashids.js.

AUTHOR
======

Bahtiar `kalkin-` Gadimov <bahtiar@gadimov.de>

Follow me [@_kalkin](https://twitter.com/_kalkin) Or [https://bahtiar.gadimov.de/](https://bahtiar.gadimov.de/)

COPYRIGHT
=========

Copyright 2016 Bahtiar `kalkin-` Gadimov.

LICENSE
=======

MIT License. See the LICENSE file. You can use Hashids in open source projects and commercial products.
