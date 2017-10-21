NAME
====

Color::Named - Work with named colors

SYNOPSIS
========

    use Color::Named;        # load the X11 color set
    use Color::Named <X11>;  # same
    use Color::Named <XKCD>; # load the XKCD color set

    # these are all identical
    my $color = Color::Named.new( :name<antiquewhite> );
    my $color = Color::Named.new( :name<antique white> );
    my $color = Color::Named.new( :name<Antique White> );

    say "Bazinga!" if $color ~~ Color;
    say $color.name;        #antiquewhite
    say $color.pretty-name; #Antique White

DESCRIPTION
===========

`Color::Named` is a subclass of `Color`. It adds a new constructor to which you can pass the name of a color. The name must be defined in your chosen color set.

You can choose from (currently) three color sets: X11, CSS3 and the xkcd set from the [xkcd color survey](https://xkcd.com/color/rgb/).

The X11 and CSS3 sets are basically [identical](https://en.wikipedia.org/wiki/X11_color_names), except for 4 colors.

**Note:**

Other than `Color` objects, instances of `Color::Named` stringify to the pretty name (with spaces, title cased) of the color.

AUTHOR
======

    Markus «Holli» Holzer

COPYRIGHT AND LICENSE
=====================

Copyright © Markus Holzer ( holli.holzer@gmail.com )

License GPLv3: The GNU General Public License, Version 3, 29 June 2007 <https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
