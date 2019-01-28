#!/usr/bin/env perl6
use v6.c;

use Test;
use Zodiac::Chinese;

my $zodiac;
my $year  = 2018;
my $month = 2;

$zodiac = ChineseZodiac.new(DateTime.new(year => $year, month => $month));

ok $zodiac.direction eq 'yang', 'even is yang';

$year = $year + 1;
$zodiac = ChineseZodiac.new(DateTime.new(year => $year, month => $month));

ok $zodiac.direction eq 'yin', 'odd is yin';

done-testing;
