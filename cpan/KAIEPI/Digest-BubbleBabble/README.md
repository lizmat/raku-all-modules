[![Build Status](https://travis-ci.org/Kaiepi/p6-Digest-BubbleBabble.svg?branch=master)](https://travis-ci.org/Kaiepi/p6-Digest-BubbleBabble)

NAME
====

Digest::BubbleBabble - Support for BubbleBabble string encoding and decoding

SYNOPSIS
========

    use Digest::BubbleBabble;

    my $digest = 'BubbleBabble is useful!'.encode;
    my $fingerprint = Digest::BubbleBabble.encode($digest);
    say $fingerprint.decode; # xidez-kidoh-sucen-furyd-sodyz-gidem-doled-cezof-rexux

    $digest = Digest::BubbleBabble.decode($fingerprint);
    say $digest.decode; # BubbleBabble is useful!

    say Digest::BubbleBabble.validate('xexax'.encode);        # True
    say Digest::BubbleBabble.validate('YXl5IGxtYW8K'.encode); # False

DESCRIPTION
===========

Digest::BubbleBabble is a way of encoding digests in such a way that it can be more easily legible and memorable for humans. This is useful for cryptographic purposes.

METHODS
=======

  * **Digest::BubbleBabble.encode**(Blob *$digest* --> Blob)

Returns the given digest blob, encoded as a BubbleBabble fingerprint.

  * **Digest::BubbleBabble.decode**(Blob *$fingerprint* --> Blob)

Returns the decoded BubbleBabble fingerprint blob. This throws an `X::Digest::BubbleBabble::Decode` exception if the fingerprint provided does not follow BubbleBabble encoding.

  * **Digest::BubbleBabble.validate**(Blob *$fingerprint* --> Bool)

This validates whether or not a fingerprint uses valid BubbleBabble encoding. Returns `True` when the fingerprint is valid, and `False` otherwise.

AUTHOR
======

Ben Davies (kaiepi)

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

