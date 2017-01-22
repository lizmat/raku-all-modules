#!/usr/bin/env perl6
use v6;
use Test;
plan 2;
use lib '.';
use IRC::TextColor;

my $irc = slurp 't/02-irc.txt';
is irc-style-text('text', :style<bold>, :color<teal>, :bgcolor<blue>), $irc, "irc-style-text works";
is ircstyle('text', :bold, :teal), irc-style-text('text', :color('teal'), :style('bold'));