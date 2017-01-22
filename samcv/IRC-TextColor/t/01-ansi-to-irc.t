#!/usr/bin/env perl6
use v6;
use Test;
plan 1;
use lib '.';
use IRC::TextColor;
my $ansi = slurp 't/01-ansi.txt';
my $irc = slurp 't/01-irc.txt';
is ansi-to-irc($ansi), $irc, "ANSI to irc conversion works";
