[![Build Status](https://travis-ci.org/kuerbis/Term-Choose-Util-p6.svg?branch=master)](https://travis-ci.org/kuerbis/Term-Choose-Util-p6)

NAME
====

Term::Choose::Util - CLI related functions.

VERSION
=======

Version 0.016

DESCRIPTION
===========

This module provides some CLI related functions.

ROUTINES
========

Values in brackets are default values.

choose-a-dir
------------

        $chosen_directory = choose-a-dir( { layout => 1, ... } )

With `choose-a-dir` the user can browse through the directory tree (as far as the granted rights permit it) and choose a directory which is returned.

To move around in the directory tree:

- select a directory and press `Return` to enter in the selected directory.

- choose the "up"-menu-entry ("`.. `") to move upwards.

To return the current working-directory as the chosen directory choose "`= `".

The "back"-menu-entry ("`E<lt> `") causes `choose-a-dir` to return nothing.

As an argument it can be passed a hash. With this hash the user can set the different options:

  * current

If set, `choose-a-dir` shows *current* as the current directory.

  * dir

Set the starting point directory. Defaults to the home directory (`$*HOME`).

  * enchanted

If set to 1, the default cursor position is on the "up" menu entry. If the directory name remains the same after an user input, the default cursor position changes to "back".

If set to 0, the default cursor position is on the "back" menu entry.

Values: 0,[1].

  * justify

Elements in columns are left justified if set to 0, right justified if set to 1 and centered if set to 2.

Values: [0],1,2.

  * layout

See the option *layout* in [Term::Choose](https://github.com/kuerbis/Term-Choose-p6)

Values: 0,[1],2.

  * mouse

See the option *mouse* in [Term::Choose](https://github.com/kuerbis/Term-Choose-p6)

Values: [0],1.

  * order

If set to 1, the items are ordered vertically else they are ordered horizontally.

This option has no meaning if *layout* is set to 2.

Values: 0,[1].

  * show-hidden

If enabled, hidden directories are added to the available directories.

Values: 0,[1].

choose-a-file
-------------

        $chosen_file = choose-a-file( { layout => 1, ... } )

Browse the directory tree like with `choose-a-dir`. Select "`E<gt>F`" to get the files of the current directory; than the chosen file is returned.

The options are passed with a hash. See [#choose-a-dir](#choose-a-dir) for the different options. `choose-a-file` has no option *current*.

choose-dirs
-----------

        @chosen_directories = choose-dirs( { layout => 1, ... } )

`choose-dirs` is similar to `choose-a-dir` but it is possible to return multiple directories.

"`. `" adds the current directory to the list of chosen directories and "`= `" returns the chosen list of directories.

The "back"-menu-entry ( "`E<lt> `" ) resets the list of chosen directories if any. If the list of chosen directories is empty, "`E<lt> `" causes `choose-dirs` to return nothing.

`choose-dirs` uses the same option as `choose-a-dir`. The option *current* expects as its value an array (directories shown as the current directories).

choose-a-number
---------------

        for ( 1 .. 5 ) {
            $current = $new
            $new = choose-a-number( 5, { current => $current, name => 'Testnumber' }  );
        }

This function lets you choose/compose a number (unsigned integer) which is returned.

The fist argument - "digits" - is an integer and determines the range of the available numbers. For example setting the first argument to 6 would offer a range from 0 to 999999.

The optional second argument is a hash with these keys (options):

  * current

The current value (integer). If set, two prompt lines are displayed - one for the current number and one for the new number.

  * name

Sets the name of the number seen in the prompt line.

Default: empty string ("");

  * mouse

See the option *mouse* in [Term::Choose](https://github.com/kuerbis/Term-Choose-p6)

Values: [0],1.

  * thsd-sep

Sets the thousands separator.

Default: comma (,).

choose-a-subset
---------------

        $subset = choose-a-subset( @available_items, { current => @current_subset } )

`choose-a-subset` lets you choose a subset from a list.

As a first argument it is required an array which provides the available list.

The optional second argument is a hash. The following options are available:

  * current

This option expects as its value the current subset of the available list (array). If set, two prompt lines are displayed - one for the current subset and one for the new subset. Even if the option *index* is true the passed current subset is made of values and not of indexes.

The subset is returned as an array.

  * index

If true, the index positions in the available list of the made choices is returned.

  * justify

Elements in columns are left justified if set to 0, right justified if set to 1 and centered if set to 2.

Values: [0],1,2.

  * layout

See the option *layout* in [Term::Choose](https://github.com/kuerbis/Term-Choose-p6).

Values: 0,1,[2].

  * mouse

See the option *mouse* in [Term::Choose](https://github.com/kuerbis/Term-Choose-p6)

Values: [0],1.

  * order

If set to 1, the items are ordered vertically else they are ordered horizontally.

This option has no meaning if *layout* is set to 2.

Values: 0,[1].

  * prefix

*prefix* expects as its value a string. This string is put in front of the elements of the available list before printing. The chosen elements are returned without this *prefix*.

The default value is "- " if the *layout* is 2 else the default is the empty string ("").

  * prompt

The prompt line before the choices.

Defaults to "Choose:".

AUTHOR
======

Matthäus Kiem <cuer2s@gmail.com>

CREDITS
=======

Thanks to the people from [Perl-Community.de](http://www.perl-community.de), from [stackoverflow](http://stackoverflow.com) and from [#perl6 on irc.freenode.net](irc://irc.freenode.net/#perl6) for the help.

LICENSE AND COPYRIGHT
=====================

Copyright 2016 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
