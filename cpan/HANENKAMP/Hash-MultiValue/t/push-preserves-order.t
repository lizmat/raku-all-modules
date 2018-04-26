#!/usr/bin/env perl6

use v6;

use Test;
use Hash::MultiValue;

my @start = a => 1, b => 2;

my %mv := Hash::MultiValue.new(pairs => @start);
%mv<a> :delete;
%mv.push: b => 3;

is %mv<b>, 3, 'b = 3';
is-deeply %mv('b'), (2, 3), 'b = 2, 3';

done-testing;
