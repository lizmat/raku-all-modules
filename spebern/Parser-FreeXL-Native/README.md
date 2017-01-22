[![Build Status](https://travis-ci.org/spebern/Parser-FreeXL-Native.svg?branch=master)](https://travis-ci.org/spebern/Parser-FreeXL-Native)

NAME
====

Parser::FreeXL::Native - wrapper for freexl parsing .xls files

SYNOPSIS
========

    use Parser::FreeXL::Native;

    my Parser::FreeXL::Native $parser .= new;
    $parser.open('file.xls');

    my $sheet_count = $parser.sheet_count;

    $parser.select_sheet(1);
    $parser.select_sheet('sheet_1');

    my @sheet_names = $parser.sheet_names;

    my ($max_row, $max_col) = $parser.sheet_dimensions;

    for ^$max_row -> $row {
        for ^$max_col -> $col {
            my $cell  = $parser.get_cell($row, $col);
            # types: <int double text date datetime time>, Nil
            my $type  = $cell.type;
            my $value = $cell.value;

            # do something with type and value
        }
    }

DESCRIPTION
===========

Parser::FreeXL::Native is a parser for xls using the freexl c library

Windows support is planned. Currently the dll is missing.

AUTHOR
======

spebern <bernhard@specht.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 spebern

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
