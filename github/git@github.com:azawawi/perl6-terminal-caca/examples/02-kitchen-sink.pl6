#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Terminal::Caca;

# Initialize library
given my $o = Terminal::Caca.new {

    # Helper subroutine that returns a random number
    constant MAX = 31;
    my sub r { (^MAX).pick }

    # Set the window title
    .title("Perl 6 rocks");

    # Draw random line types
    .color(yellow, black);
    .line(r, r, r, r, 'L');
    .thin-line(r, r, r, r);

    # Draw random box types
    .color(light-green, black);
    .box(r, r, r, r, 'b');
    .cp437-box(r, r, r, r);
    .thin-box(r, r, r, r);
    .fill-box(r, r, r, r, 'B');

    # Draw random circle types
    .color(light-red, black);
    .circle(r, r, r, 'C');

    # Draw random ellipse types
    .color(white, blue);
    .ellipse(r, r, r, r, 'e');
    .thin-ellipse(r, r, r, r);
    .fill-ellipse(r, r, r, r, 'E');

    # Draw random triangle types
    .color(yellow, black);
    .triangle(r, r, r, r, r, r, 't');
    .thin-triangle(r, r, r, r, r, r);
    .fill-triangle(r, r, r, r, r, r, 'T');

    # Draw randomly-colored polyline types
    my @points = ( ($_, r) for ^MAX );
    .color(light-blue, black);
    .polyline(@points, 'P');
    @points    = ( ($_, r) for ^MAX );
    .color(yellow, blue);
    .thin-polyline(@points);

    # Draw randomly-colored and positioned text
    .color(.random-color, .random-color);
    .text(r, r, "Hello world from Perl 6!");
    .text(r, r, "Mouse position: " ~ .mouse-position.perl);
    .text(r, r, "Window Size: "    ~ .size.perl);

    # Refresh display and wait for a key press
    .refresh;
    .wait-for-keypress;

    # Cleanup on scope exit
    LEAVE {
        .cleanup;
    }

}
