#!/usr/bin/env perl6
use v6.c;
use Test;
use Terminal::Spinners;

plan 4;

is Spinner.new.type, 'classic', 'No arguments Spinner defaults to type classic';
is Spinner.new.speed, 0.08, 'No arguments Spinner defaults to speed 0.08';
is Bar.new.type, 'hash', 'No arguments Bar defaults to type hash';
is Bar.new.length, '80', 'No arguments Bar defaults to length 80';
