#!/usr/bin/env perl6

use v6.c;

use Test;

plan 6;

use lib 'lib';

use Shell::Capture;

my Shell::Capture $c .= capture($*EXECUTABLE, '-v');
is $c.exitcode, 0, 'perl6 -v succeeded';
isnt $c.lines.elems, 0, 'perl6 -v output something';

$c .= capture($*EXECUTABLE, '-e', 'print "one#two#three#four#"', :nl('#'));
is $c.exitcode, 0, 'perl6 -e "print" succeeded';
is-deeply $c.lines, Array[Str].new(<one two three four>),
    'perl6 -e "print" said the right thing';

$c .= capture-check($*EXECUTABLE, '-e', 'print "one\0two\0thrée"', :nl("\0"), :enc('UTF-8'));
is-deeply $c.lines, Array[Str].new(<one two thrée>),
    'perl6 -e "print no nl at eol" said the right thing';

$c .= capture-check($*EXECUTABLE, '-e', 'print "\x00e1" ~ "ab\x0430"', :nl('ab'), :enc('ISO-8859-1'));
is-deeply $c.lines, Array[Str].new(<Ã¡ Ð°>),
    'decoded from ISO-8859-1';
