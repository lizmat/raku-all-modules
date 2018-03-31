[![Build Status](https://travis-ci.org/Kaiepi/p6-Net-LibIDN2.svg?branch=master)](https://travis-ci.org/Kaiepi/p6-Net-LibIDN2)

NAME
====

Net::LibIDN2 - Perl 6 bindings for GNU LibIDN2

SYNOPSIS
========

        use Net::LibIDN2;

        my $idn := Net::LibIDN2.new;

        my Int $code;
        my $ulabel := "m\xFC\xDFli";
        my $alabel := $idn.lookup_u8($ulabel, IDN2_NFC_INPUT, $code);
        say "$alabel $code"; # xn--mli-5ka8l 0

        my $result := $idn.register_u8($ulabel, $alabel, IDN2_NFC_INPUT, $code);
        say "$result $code"; # xn--mli-5ka8l 0
        say $idn.strerror($code);      # success
        say $idn.strerror_name($code); # IDN2_OK

DESCRIPTION
===========

Net::LibIDN2 is a Perl 6 wrapper for the GNU LibIDN2 library.

METHODS
=======

  * **Net::LibIDN2.check_version**(--> Str)

  * **Net::LibIDN2.check_version**(Str *$version* --> Str)

Compares *$version* against the version of LibIDN2 installed and returns either an empty string if *$version* is greater than the version installed, or *IDN2_VERSION* otherwise.

  * **Net::LibIDN2.strerror**(Int *$errno* --> Str)

Returns the error represented by *$errno* in human readable form.

  * **Net::LibIDN2.strerror_name**(Int *$errno* --> Str)

Returns the internal error name of *$errno*.

  * **Net::LibIDN2.to_ascii_8z**(Str *$input* --> Str)

  * **Net::LibIDN2.to_ascii_8z**(Str *$input*, Int *$flags* --> Str)

  * **Net::LibIDN2.to_ascii_8z**(Str *$input*, Int *$flags*, Int *$code* is rw --> Str)

Converts a UTF8 encoded string *$input* to ASCII and returns the output. *$code*, if provided, is assigned to *IDN2_OK* on success, or another error code otherwise. Requires LibIDN2 v2.0.0 or greater.

  * **Net::LibIDN2.to_unicode_8z8z**(Str *$input* --> Str)

  * **Net::LibIDN2.to_unicode_8z8z**(Str *$input*, Int *$flags* --> Str)

  * **Net::LibIDN2.to_unicode_8z8z**(Str *$input*, Int *$flags*, Int *$code* is rw --> Str)

Converts an ACE encoded domain name *$input* to UTF8 and returns the output. *$code*, if provided, is assigned to *IDN2_OK* on success, or another error code otherwise. Requires LibIDN v2.0.0 or greater.

  * **Net::LibIDN2.lookup_u8**(Str *$input* --> Str)

  * **Net::LibIDN2.lookup_u8**(Str *$input*, Int *$flags* --> Str)

  * **Net::LibIDN2.lookup_u8**(Str *$input*, Int *$flags*, Int *$code* is rw --> Str)

Performs an IDNA2008 lookup string conversion on *$input*. See RFC 5891, section 5. *$input* must be a UTF8 encoded string in NFC form if no *IDN2_NFC_INPUT* flag is passed.

  * **Net::LibIDN2.register_u8**(Str *$uinput*, Str *$ainput* --> Str)

  * **Net::LibIDN2.register_u8**(Str *$uinput*, Str *$ainput*, Int *$flags* --> Str)

  * **Net::LibIDN2.register_u8**(Str *$uinput*, Str *$ainput*, Int *$flags*, Int *$code* is rw --> Str)

Performs an IDNA2008 register string conversion on *$uinput* and *$ainput*. See RFC 5891, section 4. *$uinput* must be a UTF8 encoded string in NFC form if no *IDN2_NFC_INPUT* flag is passed. *$ainput* must be an ACE encoded string.

CONSTANTS
=========

  * Int **IDN2_LABEL_MAX_LENGTH**

The maximum label length.

  * Int **IDN2_DOMAIN_MAX_LENGTH**

The maximum domain name length.

VERSIONING
----------

  * Str **IDN2_VERSION**

The version of LibIDN2 installed.

  * Int **IDN2_VERSION_NUMBER**

The version of LibIDN2 installed represented as a 32 bit integer. The first pair of bits represents the major version, the second represents the minor version, and the last 4 represent the patch version.

  * Int **IDN2_VERSION_MAJOR**

The major version of LibIDN2 installed.

  * Int **IDN2_VERSION_MINOR**

The minor version of LidIDN2 installed.

  * Int **IDN2_VERSION_PATCH**

The patch version of LibIDN2 installed.

FLAGS
-----

  * Int **IDN2_NFC_INPUT**

Normalize the input string using the NFC format.

  * Int **IDN2_ALABEL_ROUNDTRIP**

Perform optional IDNA2008 lookup roundtrip check.

  * Int **IDN2_TRANSITIONAL**

Perform Unicode TR46 transitional processing.

  * Int **IDN2_NONTRANSITIONAL**

Perform Unicode TR46 non-transitional processing.

ERRORS
------

  * Int **IDN2_OK**

Success.

  * Int **IDN2_MALLOC**

Memory allocation failure.

  * Int **IDN2_NO_CODESET**

Failed to determine a string's encoding.

  * Int **IDN2_ICONV_FAIL**

Failed to transcode a string to UTF8.

  * Int **IDN2_ENCODING_ERROR**

Unicode data encoding error.

  * Int **IDN2_NFC**

Failed to normalize a string.

  * Int **IDN2_PUNYCODE_BAD_INPUT**

Invalid input to Punycode.

  * Int **IDN2_PUNYCODE_BIG_OUTPUT**

Punycode output buffer is too small.

  * Int **IDN2_PUNYCODE_OVERFLOW**

Punycode conversion would overflow.

  * Int **IDN2_TOO_BIG_DOMAIN**

Domain is larger than *IDN2_DOMAIN_MAX_LENGTH*.

  * Int **IDN2_TOO_BIG_LABEL**

Label is larger than *IDN2_LABEL_MAX_LENGTH*.

  * Int **IDN2_INVALID_ALABEL**

Invalid A-label.

  * Int **IDN2_UALABEL_MISMATCH**

Given U-label and A-label do not match.

  * Int **IDN2_INVALID_FLAGS**

Invalid combination of flags.

  * Int **IDN2_NOT_NFC**

String is not normalized in NFC format.

  * Int **IDN2_2HYPHEN**

String has forbidden two hyphens.

  * Int **IDN2_HYPHEN_STARTEND**

String has forbidden start/end hyphen.

  * Int **IDN2_LEADING_COMBINING**

String has forbidden leading combining character.

  * Int **IDN2_DISALLOWED**

String has disallowed character.

  * Int **IDN2_CONTEXTJ**

String has forbidden context-j character.

  * Int **IDN2_CONTEXTJ_NO_RULE**

String has context-j character without any rull.

  * Int **IDN2_CONTEXTO**

String has forbidden context-o character.

  * Int **IDN2_CONTEXTO_NO_RULE**

String has context-o character without any rull.

  * Int **IDN2_UNASSIGNED**

String has forbidden unassigned character.

  * Int **IDN2_BIDI**

String has forbidden bi-directional properties.

  * Int **IDN2_DOT_IN_LABEL**

Label has forbidden dot (TR46).

  * Int **IDN2_INVALID_TRANSITIONAL**

Label has a character forbidden in transitional mode (TR46).

  * Int **IDN2_INVALID_NONTRANSITIONAL**

Label has a character forbidden in non-transitional mode (TR46).

AUTHOR
======

Ben Davies <kaiepi@outlook.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

