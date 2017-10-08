#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Terminal::Caca::Raw;

# Initialize library
my $NULL = CacaDisplay.new;
my $dp   = caca_create_display($NULL);
my $cv   = caca_get_canvas($dp);

# Set window title
caca_set_display_title($dp, "Perl 6 rocks");

# Say hello world
my $text = ' Hello world, from Perl 6! ';
caca_set_color_ansi($cv, CACA_WHITE, CACA_BLUE);
caca_put_str($cv, 10, 10, $text);

# Draw an ASCII-art box around it
caca_draw_thin_box($cv, 9, 9, $text.chars + 2, 3);

# Refresh display
caca_refresh_display($dp);

# Wait for a key press event
caca_get_event($dp, CACA_EVENT_KEY_PRESS, $NULL, -1);

# Clean up library
caca_free_display($dp);
