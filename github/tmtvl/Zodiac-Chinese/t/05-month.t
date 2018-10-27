#!/usr/bin/env perl6
use v6.c;

use Test;
use Zodiac::Chinese;

my $zodiac_jan;
my $zodiac_feb;
my $year     = 2017;
my $january  = 1;
my $february = 2;

$zodiac_jan = ChineseZodiac.new(DateTime.new(year => $year, month => $january));
$zodiac_feb = ChineseZodiac.new(DateTime.new(year => $year, month => $february));

ok $zodiac_jan.direction ne $zodiac_feb.direction, 'dates in january have the direction of the year before';
ok $zodiac_jan.element eq $zodiac_feb.element, 'dates in january have the element of the year before';
ok $zodiac_jan.sign ne $zodiac_feb.sign, 'dates in january have the sign of the year before';

done-testing;
