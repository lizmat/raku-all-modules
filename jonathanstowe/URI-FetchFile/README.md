# URI-FetchFile

Perl6 module to retrieve a file from the internet by the best available method

[![Build Status](https://travis-ci.org/jonathanstowe/URI-FetchFile.svg?branch=master)](https://travis-ci.org/jonathanstowe/URI-FetchFile)

## Synopsis

```perl6

use URI::FetchFile;

if fetch-uri('http://rakudo.org/downloads/star/rakudo-star-2016.10.tar.gz', 'rakudo-star-2016.10.tar.gz') {
    # do something with the file
}
else {
    die "couldn't get file";
}

```

## Description

This provides a simple method of retrieving a single file via HTTP using the
best available method whilst trying to limit the dependencies.

It is intended to be used by installers or builders that may need to retrieve
a file but otherwise have no need for an HTTP client.

It will try to use the first available method from:

	* HTTP::UserAgent

	* LWP::Simple

	* curl

	* wget


Please feel free to suggest and/or implement other mechanisms.

## Installation

Assuming you have a working installation of Rakudo perl6 you cam install
this using either ```zef``` or ```panda```:

	zef install URI::FetchFile

	# or

	panda install URI::FetchFile


Other mechanisms may become available in the future.

## Support

Please make any reports, suggestions etc to https://github.com/jonathanstowe/URI-FetchFile/issues

## Licence and Copyright

© Jonathan Stowe 2016

This is free software please see the the [LICENCE](LICENCE) file for details.
