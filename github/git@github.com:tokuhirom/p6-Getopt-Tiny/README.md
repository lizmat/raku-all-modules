[![Build Status](https://travis-ci.org/tokuhirom/p6-Getopt-Tiny.svg?branch=master)](https://travis-ci.org/tokuhirom/p6-Getopt-Tiny)

NAME
====

Getopt::Tiny - Tiny option parser for Perl6

SYNOPSIS
========

    use v6;

    use Getopt::Tiny;

    my $opts = { host => '127.0.0.1', port => 5000 };

    get-options($opts, <
        e=s
        I=s@
        p=i
        h|host=s
    >);

DESCRIPTION
===========

Getopt::Tiny is tiny command line option parser library for Perl6.

FEATURES
========

  * Fluent interface

  * Built-in pod2usage feature

MOTIVATION
==========

Perl6 has a great built-in command line option parser. But it's not flexible. It's not perfect for all cases.

Function interface
==================

`get-options(Hash $opts, Array[Str] $definitions, Bool :$pass-through=False)`
-----------------------------------------------------------------------------

Here is a synopsis code:

    get-options($args, <
        e=s
        I=s@
        p=i
        h|host=s
    >);

`$definitions`' grammar is here:

    token TOP { <key> '=' <type> }
    token key { <short> [ '|' <long> ]?  | <long> }

    token short { <[a..z A..Z]> }
    token long { <[a..z A..Z]> <[a..z A..Z 0..9]>+ }

    token type {
        's'  | # str
        's@' | # array of string
        '!'  | # bool
        'i'    # int
    }

Parse options from `@*ARGS`.

`$opts` should be Hash. This function writes result to `$opts`.

`$definitions` should be one of following style.

If you want to pass-through unknown option, you can pass `:pass-through` as a named argument like following:

    get-options($x, $y, :pass-through);

This function modifies `@*ARGS` and `$PROCESS::ARGFILES`.

OO Interface
============

METHODS
-------

### `my $opt = Getopt::Tiny.new()`

Create new instance of the parser.

### `$opt.str($opt, $callback)`

If `$opt` has 1 char, it's equivalent to `$opt.str($opt, Nil, $callback)`, `$opt.str(Nil, $opt, $callback)` otherwise.

### `$opt.str($short, $long, $callback)`

Add string option.

`$short` accepts `-Ilib` or `-I lib` form. `$long` accepts `--host=lib` or `--host lib` form.

Argument of `$callback` is `Str`.

### `$opt.int($opt, $callback)`

If `$opt` has 1 char, it's equivalent to `$opt.int($opt, Nil, $callback)`, `$opt.int(Nil, $opt, $callback)` otherwise.

### `$opt.int($short, $long, $callback)`

Add integer option.

`$short` accepts `-I3` or `-I 3` form. `$long` accepts `--port=5963` or `--port 5963` form.

Argument of `$callback` is `Int`.

### `$opt.bool($opt, $callback)`

If `$opt` has 1 char, it's equivalent to `$opt.bool($opt, Nil, $callback)`, `$opt.bool(Nil, $opt, $callback)` otherwise.

### `$opt.bool($short, $long, $callback)`

Add boolean option.

`$short` accepts `-x` form. `$long` accepts `--man-pages` or `--no-man-pages` form.

Argument of `$callback` is `Bool`.

### `$opt.parse(@args)`

Run the option parser. Return values are positional arguments.

This operation does *not* modify `@*ARGS` and `$PROCESS::ARGFILES`.

pod2usage
=========

This library shows POD's SYNOPSIS section in your script as help message, when it's available.

COPYRIGHT AND LICENSE
=====================

Copyright 2015 Tokuhiro Matsuno <tokuhirom@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
