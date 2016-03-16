[![Build Status](https://travis-ci.org/kuerbis/Term-Choose-p6.svg?branch=master)](https://travis-ci.org/kuerbis/Term-Choose-p6)

NAME
====

Term::Choose - Choose items from a list interactively.

VERSION
=======

Version 0.105

SYNOPSIS
========

    use Term::Choose;

    my @array = <one two three four five>;


    # Functional interface:
     
    my $choice = choose( @array, { layout => 1 } );

    say $choice;


    # OO interface:
     
    my $tc = Term::Choose.new();

    $choice = $tc.choose( @array, { layout => 1 } );

    say $choice;

DESCRIPTION
===========

Choose interactively from a list of items.

For `choose`, `choose_multi` and `pause` the first argument (Array) holds the list of the available choices.

With the optional second argument (Hash) it can be passed the different options. See [#OPTIONS](#OPTIONS).

The return values are described in [#Routines](#Routines)

USAGE
=====

To browse through the available list-elements use the keys described below.

If the items of the list don't fit on the screen, the user can scroll to the next (previous) page(s).

If the window size is changed, after a keystroke the screen is rewritten.

How to choose the items is described for each method/function separately in [Routines](Routines).

Keys
----

  * the `Arrow` keys (or `h,j,k,l`) to move up and down or to move to the right and to the left,

  * the `Tab` key (or `Ctrl-I`) to move forward, the `BackSpace` key (or `Ctrl-H` or `Shift-Tab`) to move backward,

  * the `PageUp` key (or `Ctrl-B`) to go back one page, the `PageDown` key (or `Ctrl-F`) to go forward one page,

  * the `Home` key (or `Ctrl-A`) to jump to the beginning of the list, the `End` key (or `Ctrl-E`) to jump to the end of the list.

For the usage of `SpaceBar`, `Ctrl-SpaceBar`, `Return` and the `q`-key see [#choose](#choose), [#choose_multi](#choose_multi) and [#pause](#pause).

With *mouse* enabled (and if supported by the terminal) use the the left mouse key instead the `Return` key and the right mouse key instead of the `SpaceBar` key. Instead of `PageUp` and `PageDown` it can be used the mouse wheel. - Mouse wheel not yet suppoerted! 

Routines
========

choose
------

`choose` allows the user to choose one item from a list: the highlighted item is returned when `Return` is pressed.

`choose` returns nothing if the `q` key or `Ctrl-D` is pressed.

choose_multi
------------

The user can choose many items.

To choose more than one item mark an item with the `SpaceBar`. `choose_multi` then returns the list of the marked items including the highlighted item.

`Ctrl-SpaceBar` (or `Ctrl-@`) inverts the choices: marked items are unmarked and unmarked items are marked. If the cursor is on the first row, `Ctrl-SpaceBar` inverts the choices for the whole list else `Ctrl-SpaceBar` inverts the choices for the current page.

`choose_multi` returns nothing if the `q` key or `Ctrl-D` is pressed.

pause
-----

Nothing can be chosen, nothing is returned but the user can move around and read the output until closed with `Return`, `q` or `Ctrl-D`.

OUTPUT
======

For the output on the screen the array elements are modified.

All the modifications are made on a copy of the original array so `choose` and `choose_multi` return the chosen elements as they were passed without modifications.

Modifications:

  * If an element is not defined, the value from the option *undef* is assigned to the element.

  * If an element holds an empty string, the value from the option *empty* is assigned to the element.

  * White-spaces in elements are replaced with simple spaces.

        $element =~ s:g/\s/ /;

  * Characters which match the Unicode character property `Other` are removed.

        $element =~ s:g/\p{C}//;

  * This mapping is made before the "`substr`" because it may change the print width of the elements.

        $element = $element.gist;

  * If the length of an element is greater than the width of the screen the element is cut.

        $element.=substr( 0, $allowed_length - 3 ) ~ '...';*

`*` `Term::Choose` uses its own function to cut strings which calculates width in print columns.

OPTIONS
=======

Options which expect a number as their value expect integers.

beep
----

0 - off (default)

1 - on

default
-------

With the option *default* it can be selected an element, which will be highlighted as the default instead of the first element.

*default* expects a zero indexed value, so e.g. to highlight the third element the value would be *2*.

If the passed value is greater than the index of the last array element, the first element is highlighted.

Allowed values: 0 or greater

(default: undefined)

empty
-----

Sets the string displayed on the screen instead an empty string.

default: "ltemptygt"

index
-----

0 - off (default)

1 - return the indices of the chosen elements instead of the chosen elements.

This option has no meaning for `pause`.

justify
-------

0 - elements ordered in columns are left-justified (default)

1 - elements ordered in columns are right-justified

2 - elements ordered in columns are centered

keep
----

*keep* prevents that all the terminal rows are used by the prompt lines.

Setting *keep* ensures that at least *keep* terminal rows are available for printing "list"-rows.

If the terminal height is less than *keep*, *keep* is set to the terminal height.

Allowed values: 1 or greater

(default: 5)

layout
------

From broad to narrow: 0 > 1 > 2

  * 0 - layout off

        .-------------------.   .-------------------.   .-------------------.   .-------------------.
        | .. .. .. .. .. .. |   | .. .. .. .. .. .. |   | .. .. .. .. .. .. |   | .. .. .. .. .. .. |
        |                   |   | .. .. .. .. .. .. |   | .. .. .. .. .. .. |   | .. .. .. .. .. .. |
        |                   |   |                   |   | .. .. .. ..       |   | .. .. .. .. .. .. |
        |                   |   |                   |   |                   |   | .. .. .. .. .. .. |
        |                   |   |                   |   |                   |   | .. .. .. .. .. .. |
        |                   |   |                   |   |                   |   | .. .. .. .. .. .. |
        '-------------------'   '--- ---------------'   '-------------------'   '-------------------'

  * 1 - (default)

        .-------------------.   .-------------------.   .-------------------.   .-------------------.
        | .. .. .. .. .. .. |   | .. .. .. ..       |   | .. .. .. .. ..    |   | .. .. .. .. .. .. |
        |                   |   | .. .. .. ..       |   | .. .. .. .. ..    |   | .. .. .. .. .. .. |
        |                   |   | .. ..             |   | .. .. .. .. ..    |   | .. .. .. .. .. .. |
        |                   |   |                   |   | .. .. .. .. ..    |   | .. .. .. .. .. .. |
        |                   |   |                   |   | .. .. ..          |   | .. .. .. .. .. .. |
        |                   |   |                   |   |                   |   | .. .. .. .. .. .. |
        '-------------------'   '-------------------'   '-------------------'   '-------------------'

  * 2 - all in a single column

        .-------------------.   .-------------------.   .-------------------.   .-------------------.
        | ..                |   | ..                |   | ..                |   | ..                |
        | ..                |   | ..                |   | ..                |   | ..                |
        | ..                |   | ..                |   | ..                |   | ..                |
        |                   |   | ..                |   | ..                |   | ..                |
        |                   |   |                   |   | ..                |   | ..                |
        |                   |   |                   |   |                   |   | ..                |
        '-------------------'   '-------------------'   '-------------------'   '-------------------'

lf
--

If *prompt* lines are folded, the option *lf* allows to insert spaces at beginning of the folded lines.

The option *lf* expects a array with one or two elements:

- the first element (`INITIAL_TAB`) sets the number of spaces inserted at beginning of paragraphs

- a second element (`SUBSEQUENT_TAB`) sets the number of spaces inserted at the beginning of all broken lines apart from the beginning of paragraphs

Allowed values for the two elements are: 0 or greater.

(default: undefined)

mark
----

This is a `choose_multi`-only option.

*mark* expects as its value an array. The elements of the array are list indexes. `choose` preselects the list-elements correlating to these indexes.

(default: undefined)

max_height
----------

If defined sets the maximal number of rows used for printing list items.

If the available height is less than *max_height*, *max_height* is set to the available height.

Height in this context means number of print rows.

*max_height* overwrites *keep* if *max_height* is set to a value less than *keep*.

Allowed values: 1 or greater

(default: undefined)

max_width
---------

If defined, sets the maximal output width to *max_width* if the terminal width is greater than *max_width*.

To prevent the "auto-format" to use a width less than *max_width* set *layout* to `0`.

Width refers here to the number of print columns.

Allowed values: 2 or greater

(default: undefined)

mouse
-----

0 - no mouse (default)

1 - mouse enabled

no_spacebar
-----------

This is a `choose_multi`-only option.

*no_spacebar* expects as its value an array. The elements of the array are indexes of choices which should not be markable with the `SpaceBar` or with the right mouse key. If an element is preselected with the option *mark* and also marked as not selectable with the option *no_spacebar*, the user can not remove the preselection of this element.

(default: undefined)

order
-----

If the output has more than one row and more than one column:

0 - elements are ordered horizontally

1 - elements are ordered vertically (default)

pad
---

Sets the number of whitespaces between columns. (default: 2)

Allowed values: 0 or greater

pad_one_row
-----------

Sets the number of whitespaces between elements if we have only one row. (default: value of the option *pad*)

Allowed values: 0 or greater

page
----

0 - off

1 - print the page number on the bottom of the screen if there is more then one page. (default)

prompt
------

If *prompt* is undefined, a default prompt-string will be shown.

If the *prompt* value is an empty string (""), no prompt-line will be shown.

default: *multiselect* == `0` ?? `Close with ENTER` !! `Your choice:`. 

undef
-----

Sets the string displayed on the screen instead an undefined element.

default: "ltundefgt"

REQUIREMENTS
============

Monospaced font
---------------

It is required a terminal that uses a monospaced font which supports the printed characters.

libncurses
----------

See *Installation* and *Environment variables* in [NCurses](https://github.com/azawawi/perl6-ncurses).

AUTHOR
======

Matthäus Kiem <cuer2s@gmail.com>

CREDITS
=======

Based on the `choose` function from the [Term::Clui](https://metacpan.org/pod/Term::Clui) module.

Thanks to the people from [Perl-Community.de](http://www.perl-community.de), from [stackoverflow](http://stackoverflow.com) and from [#perl6 on irc.freenode.net](irc://irc.freenode.net/#perl6) for the help.

LICENSE AND COPYRIGHT
=====================

Copyright (C) 2016 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
