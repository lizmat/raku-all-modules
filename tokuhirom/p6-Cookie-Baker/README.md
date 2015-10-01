[![Build Status](https://travis-ci.org/tokuhirom/p6-Cookie-Baker.svg?branch=master)](https://travis-ci.org/tokuhirom/p6-Cookie-Baker)

NAME
====

Cookie::Baker - Cookie string generator / parser

SYNOPSIS
========

    use Cookie::Baker;

    $headers.push_header('Set-Cookie' => bake-cookie($key, $val));

    my $cookies_hashref = crush-cookie($headers.header('Cookie'));

DESCRIPTION
===========

Cookie::Baker provides simple cookie string generator and parser.

FUNCTIONS
=========

  * bake-cookie

    my $cookie = bake-cookie('foo','val');
    my $cookie = bake-cookie(
        'foo', 'val',
        path => "test",
        domain => '.example.com',
        expires => '+24h'
    );

Generates a cookie string for an HTTP response header. The first argument is the cookie's name and the second argument is a plain string or hash reference that can contain keys such as `value`, `domain`, `expires`, `path`, `httponly`, `secure`, `max-age`.

  * value

Cookie's value

  * domain

Cookie's domain.

  * expires

Cookie's expires date time. Several formats are supported

    expires => time + 24 * 60 * 60 # epoch time
    expires => 'Wed, 03-Nov-2010 20:54:16 GMT' 
    expires => '+30s' # 30 seconds from now
    expires => '+10m' # ten minutes from now
    expires => '+1h'  # one hour from now 
    expires => '-1d'  # yesterday (i.e. "ASAP!")
    expires => '+3M'  # in three months
    expires => '+10y' # in ten years time
    expires => 'now'  #immediately

  * path

Cookie's path.

  * httponly

If true, sets HttpOnly flag. false by default.

  * secure

If true, sets secure flag. false by default.

  * crush-cookie

Parses cookie string and returns a hashref. 

    my %cookies_hashref = crush-cookie($headers.header('Cookie'));
    my $cookie_value = %cookies_hashref<cookie_name>;

AUTHOR
======

Tokuhiro Matsuno lttokuhirom@gmail.comgt.

And original perl5 code is written by:

Masahiro Nagano ltkazeburo@gmail.comgt

COPYRIGHT AND LICENSE
=====================

Perl6 port is:

    Copyright 2015 Tokuhiro Matsuno <tokuhirom@gmail.com>

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Original Perl5 code is:

    Copyright (C) Masahiro Nagano.

    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself.
