[![Build Status](https://travis-ci.org/Kaiepi/p6-Crypt-CAST5.svg?branch=master)](https://travis-ci.org/Kaiepi/p6-Crypt-CAST5)

NAME
====

Crypt::CAST5 - CAST5 encryption library

SYNOPSIS
========

    use Crypt::CAST5;

    my Crypt::CAST5 $cast5   .= new: 'ayy lmao'.encode;
    my Str          $in       = 'sup my dudes';
    my Blob         $encoded  = $cast5.encode: $in.encode;
    my Blob         $decoded  = $cast5.decode: $encoded;
    my Str          $out      = $decoded.decode;

    say $out; # OUTPUT: sup my dudes

DESCRIPTION
===========

Crypt::CAST5 is a library that handles encryption and decryption using the CAST5 algorithm. Currently, only the ECB block cipher mode is supported.

METHODS
=======

  * **new**(Blob *$key*)

Constructs a new instance of Crypt::CAST5 using the given key. The key must be 5-16 characters long. 

  * **encode**(Blob *$plaintext* --> Blob)

Encodes `$plaintext` using CAST5 encryption.

  * **decode**(Blob *$ciphertext* --> Blob)

Decodes `$ciphertext` using CAST5 decryption.

AUTHOR
======

Ben Davies (Kaiepi)

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

