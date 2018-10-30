#!/usr/bin/env perl6

use v6;

say "Generating Markdown documentation for GTK::Simple...";
shell("perl6 -Ilib --doc=Markdown lib/GTK/Simpler.pm6 >doc/GTK-Simpler.md");
