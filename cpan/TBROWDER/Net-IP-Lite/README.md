# Net::IP::Lite

[![Build Status](https://travis-ci.org/tbrowder/Net-IP-Lite-Perl6.svg?branch=master)]
  (https://travis-ci.org/tbrowder/Net-IP-Lite-Perl6)

This is a limited Perl 6 version of CPAN's Perl 5 module
[Net::IP](https://metacpan.org/pod/Net::IP).  It provides a subset of
that module's basic IPv4 and IPv6 address manipulation subroutines.

See the Wikipedia article
[IP Address](https://en.wikipedia.org/wiki/IP_address) for a detailed
introduction to IP addresses along with links to the authoritative
RFCs.

## Status

This early version (less than 1.0.0) is considered usable, but the
APIs are subject to change until version 1.0.0 is released.

## Debugging

For debugging, use one the following methods:

- set the module's $DEBUG variable:

```Perl6
$Net::IP::Lite::DEBUG = True;
```

- set the environment variable:

```Perl6
NET_IP_LITE_DEBUG=1
```

## Subroutines Exported by Default

```Perl6
use Net::IP::Lite;
```

See
[DEFAULT-SUBS](https://github.com/tbrowder/Net-IP-Lite-Perl6/blob/master/docs/DEFAULT-SUBS.md)
for a list of default-exported subroutines, each with a short
description along with its complete signature.

## Additional Subroutines Exported with Named Parameter `:util`

```Perl6
use Net::IP::Lite :util;
```

The `:util` subroutines are used internally by the default exported
subroutines. Users should not normally need them, but there are some
handy numerical base conversion routines that may not be available elsewhere:

- bin2hex
- bin2dec
- hex2bin
- hex2dec
- dec2hex
- dec2bin

See [UTIL-SUBS](https://github.com/tbrowder/Net-IP-Lite-Perl6/blob/master/docs/UTIL-SUBS.md)
for details of each plus some other utility subroutines.

## Current Limitations

Addresses must be in "plain" format (no CIDR or other network information).

For the moment, no consideration for addresses is made for invalidity
other than the format.

## Installation

Use one of the following two methods for a normal Perl 6 environment:

```Perl6
zef install Net::IP::Lite
panda install Net::IP::Lite
```

If either attempt shows that the module isn't found or available, ensure your installer is current:

```Perl6
zef update
panda update
```

If you want to use the latest version in the git repository, clone it and then:

```Perl6
cd /path/to/cloned/repository/directory
zef install .
```

or

```Perl6
panda install .
```

## Development

It is the intent of this author to gradually add functions from the
parent module as needed, eventually approaching its full
functionality. Interested users are encouraged to contribute
improvements and corrections to this module, and pull requests, bug
reports, and suggestions are always welcome.

While testing will be normally be done as part of the zef or panda
installation, cloning this project will result in a Makefile that can
be used in fine-tuning tests and yielding more verbose results during
the development process. The Makefile can be tailored as desired.

 Note the bin directory has a utility program to generate markdown
files with certain formatting.

## Acknowledgements

This module is indebted to the CPAN Perl
[IP::Net](https://metacpan.org/pod/Net::IP) module authors for
providing such a useful set of subroutines:

- Manuel Valente <manuel.valente@gmail.com>

- Monica Cortes Sack <mcortes@ripe.net>

- Lee Wilmot <lee@ripe.net>
