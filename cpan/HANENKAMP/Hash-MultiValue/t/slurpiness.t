#!/usr/bin/env perl6

use v6;

use Test;
use Hash::MultiValue;

my @a = a => 1, b => 2;
my @b = a => 3, c => 4;

my %mv-a := Hash::MultiValue.from-pairs(@a);
is %mv-a<a>, 1, 'mv-a a = 1';
is %mv-a<b>, 2, 'mv-a b = 2';

my %mv-ab := Hash::MultiValue.from-pairs(@a, @b);
is %mv-ab<a>, 3, 'mv-ab a = 3';
is %mv-ab('a'), (1, 3), 'mv-ab a = 1, 3';
is %mv-ab<b>, 2, 'mv-ab b = 2';
is %mv-ab<c>, 4, 'mv-ab c = 4';

my %mv-ab-s := Hash::MultiValue.from-pairs(|@a, |@b);
is %mv-ab-s<a>, 3, 'mv-ab-s a = 3';
is %mv-ab-s('a'), (1, 3), 'mv-ab-s a = 1, 3';
is %mv-ab-s<b>, 2, 'mv-ab-s b = 2';
is %mv-ab-s<c>, 4, 'mv-ab-s c = 4';

done-testing;
