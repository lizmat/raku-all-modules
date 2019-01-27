[![Build Status](https://travis-ci.org/kuerbis/Term-Choose-p6.svg?branch=master)](https://travis-ci.org/kuerbis/Term-Choose-p6)

NAME
====

Term::Choose - Choose items from a list interactively.

SYNOPSIS
========

    use Term::Choose :choose;

    my @list = <one two three four five>;


    # Functional interface:
     
    my $chosen = choose( @list, :layout(2) );


    # OO interface:
     
    my $tc = Term::Choose.new( :1mouse, :0order ) );

    $chosen = $tc.choose( @list, :1layout, :2default );

DESCRIPTION
===========

Choose interactively from a list of items.

For `choose`, `choose-multi` and `pause` the first argument holds the list of the available choices.

The different options can be passed as key-values pairs. See [OPTIONS](#OPTIONS) to find the available options.

The return values are described in [Routines](#Routines)

USAGE
=====

To browse through the available list-elements use the keys described below.

If the items of the list don't fit on the screen, the user can scroll to the next (previous) page(s).

If the window size is changed, the screen is rewritten.

How to choose the items is described for each method/function separately in [Routines](Routines).

Keys
----

  * the `Arrow` keys (or `h,j,k,l`) to move up and down or to move to the right and to the left,

  * the `Tab` key (or `Ctrl-I`) to move forward, the `BackSpace` key (or `Ctrl-H` or `Shift-Tab`) to move backward,

  * the `PageUp` key (or `Ctrl-B`) to go back one page, the `PageDown` key (or `Ctrl-F`) to go forward one page,

  * the `Insert` key to go back 25 pages, the `Delete` key to go forward 25 pages,

  * the `Home` key (or `Ctrl-A`) to jump to the beginning of the list, the `End` key (or `Ctrl-E`) to jump to the end of the list.

For the usage of `SpaceBar`, `Ctrl-SpaceBar`, `Return` and the `q`-key see [choose](#choose), [choose-multi](#choose-multi) and [pause](#pause).

With *mouse* enabled use the the left mouse key instead the `Return` key and the right mouse key instead of the `SpaceBar` key. Instead of `PageUp` and `PageDown` it can be used the mouse wheel. The mouse wheel only works, if the ncurses library supports the extended mouse mode.

CONSTRUCTOR
===========

The constructor method `new` can be called with named arguments. For the valid options see [OPTIONS](#OPTIONS). Setting the options in `new` overwrites the default values for the instance.

Additionally to the options mentioned below one can set the option [win](win). The opton [win](win) expects as its value a `WINDOW` object - the return value of [NCurses](NCurses) `initscr`.

If set, `choose`, `choose-multi` and `pause` use this global window instead of creating their own without calling `endwin` to restores the terminal before returning.

ROUTINES
========

choose
------

`choose` allows the user to choose one item from a list: the highlighted item is returned when `Return` is pressed.

`choose` returns nothing if the `q` key or `Ctrl-D` is pressed.

choose-multi
------------

The user can choose many items.

To choose more than one item mark an item with the `SpaceBar`. `choose-multi` then returns the list of the marked items including the highlighted item.

`Ctrl-SpaceBar` (or `Ctrl-@`) inverts the choices: marked items are unmarked and unmarked items are marked.

`choose-multi` returns nothing if the `q` key or `Ctrl-D` is pressed.

pause
-----

Nothing can be chosen, nothing is returned but the user can move around and read the output until closed with `Return`, `q` or `Ctrl-D`.

OUTPUT
======

For the output on the screen the elements of the list are copied and then modified. Chosen elements are returned as they were passed without modifications.

Modifications:

If an element is not defined, the value from the option *undef* is assigned to the element. If an element holds an empty string, the value from the option *empty* is assigned to the element.

White-spaces in elements are replaced with simple spaces: `$_ =~ s:g/\s/ /`. Invalid characers (Unicode character proterty `Other`) are removed: `$_=~ s:g/\p{C}//`.

If the length (print columns) of an element is greater than the width of the screen the element is cut and three dots are attached.

OPTIONS
=======

Options which expect a number as their value expect integers.

### beep

0 - off (default)

1 - on

### default

With the option *default* it can be selected an element, which will be highlighted as the default instead of the first element.

*default* expects a zero indexed value, so e.g. to highlight the third element the value would be *2*.

If the passed value is greater than the index of the last array element, the first element is highlighted.

Allowed values: 0 or greater

(default: undefined)

### empty

Sets the string displayed on the screen instead an empty string.

default: "ltemptygt"

### info

Expects as its value a string. The string is printed above the prompt string.

### index

0 - off (default)

1 - return the indices of the chosen elements instead of the chosen elements.

This option has no meaning for `pause`.

### justify

0 - elements ordered in columns are left-justified (default)

1 - elements ordered in columns are right-justified

2 - elements ordered in columns are centered

### keep

*keep* prevents that all the terminal rows are used by the prompt lines.

Setting *keep* ensures that at least *keep* terminal rows are available for printing "list"-rows.

If the terminal height is less than *keep*, *keep* is set to the terminal height.

Allowed values: 1 or greater

(default: 5)

### layout

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

### lf

If *prompt* lines are folded, the option *lf* allows one to insert spaces at beginning of the folded lines.

The option *lf* expects a list with one or two elements:

- the first element (`INITIAL_TAB`) sets the number of spaces inserted at beginning of paragraphs

- a second element (`SUBSEQUENT_TAB`) sets the number of spaces inserted at the beginning of all broken lines apart from the beginning of paragraphs

Allowed values for the two elements are: 0 or greater.

(default: undefined)

### max-height

If defined sets the maximal number of rows used for printing list items.

If the available height is less than *max-height*, *max-height* is set to the available height.

Height in this context means number of print rows.

*max-height* overwrites *keep* if *max-height* is set to a value less than *keep*.

Allowed values: 1 or greater

(default: undefined)

### max-width

If defined, sets the maximal output width to *max-width* if the terminal width is greater than *max-width*.

To prevent the "auto-format" to use a width less than *max-width* set *layout* to `0`.

Width refers here to the number of print columns.

Allowed values: 2 or greater

(default: undefined)

### mouse

0 - no mouse (default)

1 - mouse enabled

### order

If the output has more than one row and more than one column:

0 - elements are ordered horizontally

1 - elements are ordered vertically (default)

### pad

Sets the number of whitespaces between columns. (default: 2)

Allowed values: 0 or greater

### page

0 - off

1 - print the page number on the bottom of the screen if there is more then one page. (default)

### prompt

If *prompt* is undefined, a default prompt-string will be shown.

If the *prompt* value is an empty string (""), no prompt-line will be shown.

### undef

Sets the string displayed on the screen instead an undefined element.

default: "ltundefgt"

options choose-multi
--------------------

### include-highlighted

0 - `choose-multi` returns the items marked with the `SpaceBar`. (default)

1 - `choose-multi` returns the items marked with the `SpaceBar` plus the highlighted item.

2 - `choose-multi` returns the items marked with the `SpaceBar`. If no items are marked with the `SpaceBar`, the highlighted item is returned.

### mark

*mark* expects as its value a list of indexes (integers). `choose-multi` preselects the list-elements correlating to these indexes.

(default: undefined)

### meta-items

*meta_items* expects as its value a list of indexes (integers). List-elements correlating to these indexes can not be marked with the `SpaceBar` or with the right mouse key but if one of these elements is the highlighted item it is added to the chosen items when `Return` is pressed.

Elements greater than the last index of the list are ignored.

(default: undefined)

### no-spacebar

*no-spacebar* expects as its value an list. The elements of the list are indexes of choices which should not be markable with the `SpaceBar` or with the right mouse key. If an element is preselected with the option *mark* and also marked as not selectable with the option *no-spacebar*, the user can not remove the preselection of this element.

(default: undefined)

ENVIRONMET VARIABLES
====================

multithreading
--------------

`Term::Choose` uses multithreading when preparing the list for the output; the number of threads to use can be set with the environment variable `TC_NUM_THREADS`.

The method `num-threads` returns the setting used by `Term::Choose`.

libncurses
----------

The location of the used ncurses library can be specified by setting the environment variable `PERL6_NCURSES_LIB`. This will overwrite the default library location.

REQUIREMENTS
============

libncurses
----------

`Term::Choose` requires `libncurses` to be installed. If the list elements contain wide characters it is required an approprirate ncurses library else wide character will break the output.

Monospaced font
---------------

It is required a terminal that uses a monospaced font which supports the printed characters.

AUTHOR
======

Matthäus Kiem <cuer2s@gmail.com>

CREDITS
=======

Based on the `choose` function from the [Term::Clui](https://metacpan.org/pod/Term::Clui) module.

Thanks to the people from [Perl-Community.de](http://www.perl-community.de), from [stackoverflow](http://stackoverflow.com) and from [#perl6 on irc.freenode.net](irc://irc.freenode.net/#perl6) for the help.

LICENSE AND COPYRIGHT
=====================

Copyright (C) 2016-2018 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
