[![Build Status](https://travis-ci.org/moznion/p6-Text-LTSV.svg?branch=master)](https://travis-ci.org/moznion/p6-Text-LTSV)

NAME
====

Text::LTSV - LTSV (Labeled Tab Separated Value) toolkit

SYNOPSIS
========

    use Text::LTSV;

    my $ltsv = Text::LTSV.new;

    ## one line
    $ltsv.stringify(Array[Pair].new(
        'foo'  => 'bar',
        'buz'  => 'qux',
        'john' => 'paul',
    )); # => "foo:bar\tbuz:qux\tjohn:paul"

    ## multiple lines
    $ltsv.stringify(Array[Array[Pair]].new(
        Array[Pair].new('foo' => 'bar'),
        Array[Pair].new('buz' => 'qux'),
    )); # => "foo:bar\nbuz:qux"

    ## With parser
    use Text::LTSV::Parser;
    my $parser = Text::LTSV::Parser.new;
    $ltsv.stringify($parser.parse-line("foo:bar\tbuz:qux\tjohn:paul\n")); # => "foo:bar\tbuz:qux\tjohn:paul"
    $ltsv.stringify($parser.parse-text("foo:bar\tbuz:qux\njohn:paul\tgeorge:ringo\n")); # => "foo:bar\tbuz:qux\njohn:paul\tgeorge:ringo"

DESCRIPTION
===========

Text::LTSV is a builder for [LTSV (Labeled Tab Separated Values)](http://ltsv.org/).

METHODS
=======

`multi method stringify(Pair @key-values) returns Str`
------------------------------------------------------

Stringify LTSV as one line.

`multi method stringify(Array[Pair] @multi-key-values) returns Str`
-------------------------------------------------------------------

Stringify LTSV as multiple lines. You can specify new line character by `$.nl`. Default `$.nl` is `"\n"`;

SEE ALSO
========

  * [Text::LTSV::Parser](Text::LTSV::Parser)

AUTHOR
======

moznion <moznion@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2015 moznion

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
