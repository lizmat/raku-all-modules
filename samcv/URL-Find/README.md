[![Build Status](https://travis-ci.org/samcv/URL-Find.svg?branch=master)](https://travis-ci.org/samcv/URL-Find)
TITLE
=====

URL::Find

SUBTITLE
========

A Perl 6 module to find all the URL's in a set of text.

DESCRIPTION
===========

By default it will match domain names that use unicode characters such as http://правительство.рф. To only match ASCII domains use the :ascii option. It will also find URL's that end in one of the restricted characters, so `https://www.google.com, ` will pull out `https://www.google.com`. It will find all the URL's in a text by default, or you can specify a maximum number with the :limit option. By default it will only find http, https, ftp, git and ssh schemes, but you can specify `:any<1>` to match any schemes with legal characters..

### sub find-urls

```
sub find-urls(
    Str $string,
    Num :$limit is copy,
    :$ascii,
    :$any
) returns List
```

Accepts a string and returns a list of URL's. Optionally you can specify a limit to the number of URL's returned, or whether you want to only match URL's with ASCII domain names: :ascii<1> Matches only http https ftp git and ssh schemes by default. To match any scheme, use :any<1>

AUTHOR
======

Samantha McVey (samcv) samantham@posteo.net

LICENSE
=======

This is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
