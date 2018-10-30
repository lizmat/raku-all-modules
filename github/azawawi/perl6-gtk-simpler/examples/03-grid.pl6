#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app(title => "Grid layouts!");

$app.set-content(
    grid(
        [0, 0, 1, 1] => my $tlb = button(label => "up left"),
        [1, 0, 1, 1] => my $trb = button(label => "up right"),
        [0, 1, 2, 1] => my $mid = label(text => "hey there!"),
        [0, 2, 1, 1] => my $blb = toggle-button(label => "bottom left"),
        [1, 2, 1, 1] => my $brb = toggle-button(label => "bottom right"),
        [2, 0, 1, 3] => my $sdl = label(text => ".\n" x 10),
    )
);

$app.border-width = 20;

$app.run;
