#!/usr/bin/env perl6
use v6.c;

use Test;
use Zodiac::Chinese;

my $obj;

lives-ok { $obj = ChineseZodiac.new(DateTime.new(year => 2018)) }, 'create an instance';

done-testing;
