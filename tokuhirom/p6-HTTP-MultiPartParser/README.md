[![Build Status](https://travis-ci.org/tokuhirom/p6-HTTP-MultiPartParser.svg?branch=master)](https://travis-ci.org/tokuhirom/p6-HTTP-MultiPartParser)

NAME
====

HTTP::MultiPartParser - low level multipart/form-data parser

SYNOPSIS
========

    use HTTP::MultiPartParser;

    $parser = HTTP::MultiPartParser.new(
        boundary  => $boundary,
        on_header => $on_header,
        on_body   => $on_body,
    );

    while $octets = read_octets_from_body() {
        $parser.parse($octets);
    }

    $parser.finish;

DESCRIPTION
===========

HTTP::MultiPartParser is low level multipart/form-data parser library.

This library is port of chansen's HTTP::MultiPartParser for Perl5.

METHODS
=======

new
---

    $parser = HTTP::MultiPartParser.new( );

This constructor returns a instance of `HTTP::MultiPartParser`. Valid  attributes inculde:

  * `boundary` (Mandatory)

    boundary => $value

The unquoted and unescaped *boundary* parameter value from the Content-Type  header field. The *boundary* parameter value consist of a restricted set of  characters as defined in [RFC 2046](RFC 2046).

    DIGIT / ALPHA / "'" / "(" / ")" /
    "+" / "_" / "," / "-" / "." /
    "/" / ":" / "=" / "?"

  * `on_header` (Mandatory)

    on_header => sub (Array[Str] $header) { ... }

This callback will be invoked when the header of a part has successfully been  received. The callback will only be invoked once for each part.

  * `on_body` (Mandatory)

    on_body => sub (Blob $chunk, Bool $final) { ... }

This callback will be invoked when there is any data available for the body  of a part. The callback may be invoked multiple times for each part.

  * `on_error`

    on_error => sub (Blob $message) { ... }

This callback will be invoked anytime an error occurs in the parser. After receiving an error the parser is no longer useful in its current state.

  * `max_preamble_size`

    max_preamble_size => 32768

  * `max_header_size`

    max_header_size => 32768

parse
-----

    $parser.parse($octets);

Parses the given octets.

finish
------

    $parser.finish;

Finish the parsing.

COPYRIGHT AND LICENSE
=====================

    Copyright 2015 Tokuhiro Matsuno <tokuhirom@gmail.com>

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And original perl5's HTTP::MutlipartParser is

    Copyright 2012-2013 by Christian Hansen.

    This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
