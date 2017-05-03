#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Terminal::Caca;

# Initialize library
my $o  = Terminal::Caca.new;

# Set window title
$o.title("Window");

# Draw some randomly-colored strings
constant MAX = 31;
for 0..MAX -> $i {
    # Choose random drawing colors
    $o.color-ansi($o.random-color, $o.random-color);

    # Draw a string
    $o.put-str(10, $i, "Hello world, from Perl 6!");
}

# Draw a totally random line using the given character
$o.color-ansi(Yellow, Black);
$o.line((^MAX).pick, (^MAX).pick, (^MAX).pick, (^MAX).pick, 'L');

# Draw a totally thin line using ASCII art
$o.color-ansi(LightMagenta, Black);
$o.thin-line((^MAX).pick, (^MAX).pick, (^MAX).pick, (^MAX).pick);

# Draw a totally random box using the given character
$o.color-ansi(White, Blue);
$o.box((^MAX).pick, (^MAX).pick, (^MAX).pick, (^MAX).pick, 'B');

# Draw a totally random thin box using ASCII art
$o.color-ansi(LightGreen, Black);
$o.thin-box((^MAX).pick, (^MAX).pick, (^MAX).pick, (^MAX).pick);

# Draw a totally random circle using the given character
$o.color-ansi(LightGreen, Black);
$o.circle((^MAX).pick, (^MAX).pick, (^MAX).pick, 'C');

# Refresh display
$o.refresh();

# Wait for a key press
$o.wait-for-keypress();

LEAVE {
    $o.cleanup if $o;
}
