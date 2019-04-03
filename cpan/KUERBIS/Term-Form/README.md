[![Build Status](https://travis-ci.org/kuerbis/Term-Form-p6.svg?branch=master)](https://travis-ci.org/kuerbis/Term-Form-p6)

NAME
====

Term::Form - Read lines from STDIN.

SYNOPSIS
========

    use Term::Form :readline, :fill-form;

    my @aoa = (
        [ 'name'           ],
        [ 'year'           ],
        [ 'color', 'green' ],
        [ 'city'           ]
    );


    # Functional interface:

    my $line = readline( 'Prompt: ', default<abc> );

    my @filled_form = fill-form( @aoa, :auto-up( 0 ) );


    # OO interface:

    my $new = Term::Form.new();

    $line = $new.readline( 'Prompt: ', :default<abc> );

    @filled_form = $new.fill-form( @aoa, :auto-up( 0 ) );

DESCRIPTION
===========

`readline` reads a line from STDIN. As soon as `Return` is pressed `readline` returns the read string without the newline character - so no `chomp` is required.

`fill-form` reads a list of lines from STDIN.

Keys
----

`BackSpace` or `Ctrl-H`: Delete the character behind the cursor.

`Delete` or `Ctrl-D`: Delete the character at point.

`Ctrl-U`: Delete the text backward from the cursor to the beginning of the line.

`Ctrl-K`: Delete the text from the cursor to the end of the line.

`Right-Arrow`: Move forward a character.

`Left-Arrow`: Move back a character.

`Home` or `Ctrl-A`: Move to the start of the line.

`End` or `Ctrl-E`: Move to the end of the line.

`Up-Arrow`:

- `fill-form`: move up one row.

- `readline` move back 10 characters.

`Down-Arrow`:

- `fill-form`: move down one row.

- `readline`: move forward 10 characters.

Only in `readline`:

`Ctrl-X`: `readline` returns nothing (undef).

Only in `fill-form`:

`Page-Up` or `Ctrl-B`: Move back one page.

`Page-Down` or `Ctrl-F`: Move forward one page.

METHODS
=======

new
---

The `new` method returns a `Term::Form` object.

    my $new = Term::Form.new();

`new` can be called with named arguments. For the valid options see [OPTIONS](#OPTIONS). Setting the options in `new` overwrites the default values for the instance.

readline
--------

`readline` reads a line from STDIN.

    my $line = $new.readline( $prompt, $default );

or

    my $line = $new.readline( $prompt, :$default, :$no-echo, ... );

The fist argument is the prompt string.

With the following arguments one can set the different options or instead it can be passed the default value (see option default) as a string.

  * clear-screen

0 - off (default)

1 - clear the screen before printing the choices

2 - use the alternate screen (uses the control sequence `1049`)

default: disabled

  * info

Expects as is value a string. If set, the string is printed on top of the output of `readline`.

  * default

Set a initial value of input.

  * no-echo

0 - the input is echoed on the screen

1 - "`*`" are displayed instead of the characters

2 - no output is shown apart from the prompt string

default: `0`

  * show-context

Display the input that does not fit into the "readline" before or after the "readline".

0 - disable *show-context*

1 - enable *show-context*

default: `0`

fill-form
---------

`fill-form` reads a list of lines from STDIN.

    my $new_list = $new.fill-form( @aoa, :1auto-up, ... );

The first argument is an array of arrays. The arrays have 1 or 2 elements: the first element is the key and the optional second element is the value. The key is used as the prompt string for the "readline", the value is used as the default value for the "readline" (initial value of input).

The first argument can be followed by the different options:

  * clear-screen

0 - off (default)

1 - clear the screen before printing the choices

2 - use the alternate screen (uses the control sequence `1049`)

default: disabled

  * hide-cursor

Hide the cursor (`0` or `1`).

default: enabled

  * info

Expects as is value a string. If set, the string is printed on top of the output of `fill-form`.

default: nothing

  * prompt

If *prompt* is set, a main prompt string is shown on top of the output.

default: nothing

  * auto-up

With *auto-up* set to `0` or `1` pressing `ENTER` moves the cursor to the next line (if the cursor is not on the "back" or "confirm" row). If the last row is reached, the cursor jumps to the first data row if `ENTER` is pressed. While with *auto-up* set to `0` the cursor loops through the rows until a key other than `ENTER` is pressed with *auto-up* set to `1` after one loop an `ENTER` moves the cursor to the top menu entry ("back") if no other key than `ENTER` was pressed.

With *auto-up* set to `2` an `ENTER` moves the cursor to the top menu entry (except the cursor is on the "confirm" row).

If *auto-up* is set to `0` or `1` the initially cursor position is on the first data row while when set to `2` the initially cursor position is on the first menu entry ("back").

default: `1`

  * read-only

Set a form-row to read only.

Expected value: a reference to an array with the indexes of the rows which should be read only.

default: empty array

  * confirm

Set the name of the "confirm" menu entry.

default: `Confirm`

  * back

Set the name of the "back" menu entry.

The "back" menu entry can be disabled by setting *back* to an empty string.

default: `Back`

To close the form and get the modified list select the "confirm" menu entry. If the "back" menu entry is chosen to close the form, `fill-form` returns nothing.

REQUIREMENTS
============

See [Term::Choose#REQUIREMENTS](Term::Choose#REQUIREMENTS).

AUTHOR
======

Matthäus Kiem <cuer2s@gmail.com>

CREDITS
=======

Thanks to the people from [Perl-Community.de](http://www.perl-community.de), from [stackoverflow](http://stackoverflow.com) for the help.

LICENSE AND COPYRIGHT
=====================

Copyright (C) 2016-2019 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

