[![Build Status](https://travis-ci.org/Kaiepi/p6-Net-LibIDN.svg?branch=master)](https://travis-ci.org/Kaiepi/p6-Net-LibIDN)

NAME
====

Net::LibIDN - Perl 6 bindings for GNU LibIDN

SYNOPSIS
========

    use Net::LibIDN;

    my $idna := Net::LibIDN.new;

    my $domain := "m\xFC\xDFli.de";
    my Int $code;
    my $ace := $idna.to_ascii_8z($domain, 0, $code);
    say "$ace $code"; # xn--mssli-kva.de 0

    my $domain2 := $idna.to_unicode_8z8z($domain, 0, $code);
    say "$domain2 $code"; # müssli.de 0

DESCRIPTION
===========

Net::LibIDN is a wrapper for the GNU LibIDN library. It provides bindings for its IDNA, Punycode, stringprep, and TLD functions. See Net::LibIDN::Punycode, Net::LibIDN::StringPrep, and Net::LibIDN::TLD for more documentation.

LibIDN must be installed in order to use this library. Instructions vary depending on your OS:

  * Windows

Follow the instructions on [https://www.gnu.org/software/libidn/manual/html_node/Downloading-and-Installing.html#Downloading-and-Installing](https://www.gnu.org/software/libidn/manual/html_node/Downloading-and-Installing.html#Downloading-and-Installing). Ensure the path to where LibIDN is installed is in your PATH environment variable!

  * OS X

    $ brew install libidn

  * Ubuntu/Debian

    $ sudo apt-get install libidn

  * OpenSUSE

    $ sudo zypper install libidn

  * Fedora

    $ sudo yum install libidn

  * Arch/Manjaro

    $ sudo pacman -S libidn

  * FreeBSD

    # pkg install libidn

or

    # cd /usr/ports/devel/libidn
    # make config
    # make
    # make install

  * OpenBSD

    $ doas pkg_add libidn

or

    $ cd /usr/ports/devel/libidn
    $ doas make
    $ doas make install

  * NetBSD

    # pkgin install libidn

or

    # cd /usr/pkgsrc/devel/libidn
    # make
    # make install

METHODS
=======

  * **Net::LibIDN.to_ascii_8z**(Str *$input* --> Str)

  * **Net::LibIDN.to_ascii_8z**(Str *$input*, Int *$flags* --> Str)

  * **Net::LibIDN.to_ascii_8z**(Str *$input*, Int *$flags*, Int *$code* is rw --> Str)

Converts a UTF8 encoded string `$input` to ASCII and returns the output. `$code`, if provided, is assigned to `IDNA_SUCCESS` on success, or another error code otherwise.

  * **Net::LibIDN.to_unicode_8z8z**(Str *$input* --> Str)

  * **Net::LibIDN.to_unicode_8z8z**(Str *$input*, Int *$flags* --> Str)

  * **Net::LibIDN.to_unicode_8z8z**(Str *$input*, Int *$flags*, Int *$code* is rw --> Str)

Converts an ACE encoded domain name `$input` to UTF8 and returns the output. `$code`, if provided, is assigned to `IDNA_SUCCESS` on success, or another error code otherwise.

CONSTANTS
=========

  * Int **IDNA_ACE_PREFIX**

String containing the official IDNA prefix, "xn--".

FLAGS
-----

  * Int **IDNA_ALLOW_UNASSIGNED**

Allow unassigned Unicode codepoints.

  * Int **IDNA_USE_STD3_ASCII_RULES**

Check output to ensure it is a STD3 conforming hostname.

ERRORS
------

  * Int **IDNA_SUCCESS**

Successful operation.

  * Int **IDNA_STRINGPREP_ERROR**

Error during string preparation.

  * Int **IDNA_PUNYCODE_ERROR**

Error during punycode operation.

  * Int **IDNA_CONTAINS_NON_LDH**

`IDNA_USE_STD3_ASCII_RULES` flag was passed, but the given string contained non-LDH ASCII characters.

  * Int **IDNA_CONTAINS_MINUS**

`IDNA_USE_STD3_ASCII_RULES` flag was passed, but the given string contained a leading or trailing hyphen-minus (u002D).

  * Int **IDNA_INVALID_LENGTH**

The final output string is not within the range of 1 to 63 characters.

  * Int **IDNA_NO_ACE_PREFIX**

The string does not begin with `IDNA_ACE_PREFIX` (for ToUnicode).

  * Int **IDNA_ROUNDTRIP_VERIFY_ERROR**

The ToASCII operation on the output string does not equal the input.

  * Int **IDNA_CONTAINS_ACE_PREFIX**

The input string begins with `IDNA_ACE_PREFIX` (for ToASCII).

  * Int **IDNA_ICONV_ERROR**

Could not convert string to locale encoding.

  * Int **IDNA_MALLOC_ERROR**

Could not allocate buffer (this is typically a fatal error).

  * Int **IDNA_DLOPEN_ERROR**

Could not dlopen the libcidn DSO (only used internally in LibC).

AUTHOR
======

Ben Davies (kaiepi)

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

