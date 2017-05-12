#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Terminal::Caca;

# Initialize library
given my $o = Terminal::Caca.new {
    # Set window title
    .title("Random Text");

    # Some random background text
    my @chars = 'A'..'Z';
    @chars.push($_) for 'a'..'z';
    @chars.push($_) for '0'..'9';
    for 0..79 -> $x {
        for 0..31 -> $y {
            my $c = .random-color;
            .color($c,black);
            .char($x, $y, @chars.pick)
        }
    }

    # Refresh display
    .refresh;

    # Wait for a key press event
    .wait-for-keypress;

    # Cleanup on scope exit
    LEAVE {
        $o.cleanup;
    }
}
