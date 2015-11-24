#!/usr/bin/env perl6
use v6;
use Test;
use Text::Wrap;

# original bug: https://rt.perl.org/rt3/Ticket/Display.html?id=39548

plan 2;

my Str $leading-indent =
        " (Karl-Bonhoeffer-Nervenklinik zwischen Hermann-Piper-Str. und U-Bahnhof) ";
my Str $paragraph-indent = " ";
my Str $main-text =
        "(5079,19635 5124,19634 5228,19320 5246,19244)\n";

lives-ok {
    is  wrap($leading-indent, $paragraph-indent, $main-text),
        " (Karl-Bonhoeffer-Nervenklinik zwischen Hermann-Piper-Str. und U-Bahnhof) (\n"
      ~ " 5079,19635 5124,19634 5228,19320 5246,19244)\n";
}, 'First test ran' or flunk('First test died');
