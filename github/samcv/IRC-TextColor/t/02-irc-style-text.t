#!/usr/bin/env perl6
use v6;
use Test;
plan 6;
use lib '.';
use IRC::TextColor;

my $irc = slurp 't/02-irc.txt';
is irc-style-text('text', :style<bold>, :color<teal>, :bgcolor<blue>), $irc, "irc-style-text works";
is ircstyle('text', :bold, :teal), irc-style-text('text', :color('teal'), :style('bold')), "ircstyle works with bold and color";
is ircstyle('text', :bold), irc-style-text('text', :style('bold')), "ircstyle works with just bold";
is ircstyle('text', :teal), irc-style-text('text', :color('teal')), "ircstyle texts with just color";
is-deeply irc-style-text(42), '42', 'irc-style-text can take a Cool';
is-deeply ircstyle(42),       '42', 'ircstyle can take a Cool';
