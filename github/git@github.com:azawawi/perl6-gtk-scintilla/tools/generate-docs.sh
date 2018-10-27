#!/usr/bin/env perl6

use v6;

say "Generating Markdown documentation...";
shell("perl6 -Ilib --doc=Markdown lib/GTK/Scintilla/Editor.pm6 >doc/GTK-Scintilla-Editor.md");
