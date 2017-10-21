NAME
====

Color::Scheme - Generate color schemes from a base color

SYNOPSIS
========

    use Color::Scheme;

    my $color   = Color.new( "#1A3CFA" );

    # this is the sugar
    my @palette = color-scheme( $color, 'six-tone-ccw' );

    # for this
    my @palette = color-scheme( $color, color-scheme-angles<six-tone-ccw'> );

    # debug flag, to visually inspect the colors
    # creates "colors.html" in the current directory
    my @palette = color-scheme( $color, 'triadic', :debug );

DESCRIPTION
===========

With Color::Scheme you can create schemes/palettes of colors that work well together.

You pick a base color and one of sixteen schemes and the module will generate a list of colors that harmonize. How many colors depends on the scheme.

There are 16 schemes available:

  * split-complementary (3 colors)

  * split-complementary-cw (3 colors)

  * split-complementary-ccw (3 colors)

  * triadic (3 colors)

  * clash (3 colors)

  * tetradic (4 colors)

  * four-tone-cw (4 colors)

  * four-tone-ccw (4 colors)

  * five-tone-a (5 colors)

  * five-tone-b (5 colors)

  * five-tone-cs (5 colors)

  * five-tone-ds (5 colors)

  * five-tone-es (5 colors)

  * analogous (6 colors)

  * neutral (6 colors)

  * six-tone-ccw (6 colors)

  * six-tone-cw (6 colors)

Those schemes are just lists of angles in a hash ( `Color::Scheme::color-scheme-angles`).

You can use the second form of the color-scheme sub to pass in your own angles if you have to.

AUTHOR
======

    holli.holzer@gmail.com

COPYRIGHT AND LICENSE
=====================

Copyright © holli.holzer@gmail.com

License GPLv3: The GNU General Public License, Version 3, 29 June 2007 <https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
