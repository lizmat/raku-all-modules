
[![Build Status](https://travis-ci.org/zengargoyle/Text-Fortune.svg?branch=master)](https://travis-ci.org/zengargoyle/Text-Fortune)

NAME
====

Text::Fortune - print a random adage, fortune(6), strfile(1)

SYNOPSIS
========

    use Text::Fortune;

    # Random fortune from 'fortunefile' & 'fortunefile.dat' -- fortune(6)
    my $fortune = Text::Fortune::File.new( path => $fortunefile );
    say $fortune.random;

    # Generate 'fortunefile.dat' from 'fortunefile' -- strfile(1)
    my $datfile = $fortunefile ~ '.dat';
    $datafile.IO.open(:w).write(
      Text::Fortune::Index.new.load-fortune( $fortunefile.IO.path )
    );

DESCRIPTION
===========

Text::Fortune is a minimal implementation for implementing the fortune(6) and strfile(1) progams, with functions for generating a 'fortunes.dat' file from a 'fortunes' file (strfile(1)) and for retrieving a random fortune (fortune(6)).

COPYRIGHT AND LICENSE
=====================

Copyright 2015 zengargoyle <zengargoyle@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
