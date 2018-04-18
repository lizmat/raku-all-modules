#! /usr/bin/env perl6

use v6.c;
use lib 'lib';
use Lingua::Stem::Es;
use Test;

plan 2;

is stem('abarca'), 'abarc', "Stem for abarca is abarc";
is stem('zarpó'), 'zarp', "Stem for zarpó is zarp";

done-testing;

# vim: ft=perl6 noet
