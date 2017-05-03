#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Terminal::Caca::Raw;

# Initialize library
my $NULL = CacaDisplay.new;
my $dp   = caca_create_display($NULL);
my $cv   = caca_get_canvas($dp);

# Set window title
caca_set_display_title($dp, "Window");

# Draw some strings
for 0..31 -> $i {
    caca_put_str($cv, 10, $i, "Hello world, from Perl 6!");
    my $fore-color = (1..CACA_WHITE).pick;
    my $back-color = (1..CACA_WHITE).pick;
    caca_set_color_ansi($cv, $fore-color, $back-color);
}

# Refresh display
caca_refresh_display($dp);

# Wait for a key press event
caca_get_event($dp, CACA_EVENT_KEY_PRESS, $NULL, -1);

# Clean up library
caca_free_display($dp);
