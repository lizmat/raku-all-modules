[![Build Status](https://travis-ci.org/tokuhirom/p6-HTTP-Parser.svg?branch=master)](https://travis-ci.org/tokuhirom/p6-HTTP-Parser)

NAME
====

HTTP::Parser - HTTP parser.

SYNOPSIS
========

    use HTTP::Parser;

    my ($result, $env) = parse-http-request("GET / HTTP/1.0\x0d\x0acontent-type: text/html\x0d\x0a\x0d\x0a".encode("ascii"));
    # $result => 43
    # $env => ${:CONTENT_TYPE("text/html"), :PATH_INFO("/"), :QUERY_STRING(""), :REQUEST_METHOD("GET")}

DESCRIPTION
===========

HTTP::Parser is tiny http request parser library for perl6.

FUNCTIONS
=========

  * `my ($result, $env) = sub parse-http-request(Blob[uint8] $req) is export`

parse http request.

`$req` must be `Blob[uint8]`. Not **utf8**.

Tries to parse given request string, and if successful, inserts variables into `$env`. For the name of the variables inserted, please refer to the PSGI specification. The return values are:

  * >=0

length of the request (request line and the request headers), in bytes

  * -1

given request is corrupt

  * -2

given request is incomplete

COPYRIGHT AND LICENSE
=====================

Copyright 2015 Tokuhiro Matsuno <tokuhirom@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
