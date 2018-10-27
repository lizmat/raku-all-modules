[![Build Status](https://travis-ci.org/akiym/JSON-Hjson.svg?branch=master)](https://travis-ci.org/akiym/JSON-Hjson)

NAME
====

JSON::Hjson - Human JSON (Hjson) deserializer

SYNOPSIS
========

    use JSON::Hjson;

    my $text = q:to'...';
    {
      // specify delay in
      // seconds
      delay: 1
      message: wake up!
    }
    ...
    say from-hjson($text).perl;

DESCRIPTION
===========

JSON::Hjson implements Human JSON (Hjson) in Perl6 grammar.

SEE ALSO
========

[JSON::Tiny](JSON::Tiny)

[https://hjson.org/rfc.html](https://hjson.org/rfc.html)

AUTHOR
======

Takumi Akiyama <t.akiym@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Takumi Akiyama

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
