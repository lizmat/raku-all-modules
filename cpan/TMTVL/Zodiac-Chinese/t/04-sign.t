#!/usr/bin/env perl6
use v6.c;

use Test;
use Zodiac::Chinese;

my $zodiac;
my $month = 2;

my %year_signs = (1924 => 'rat', 1925 => 'ox', 1926 => 'tiger', 1927 => 'rabbit', 1928 => 'dragon', 1929 => 'snake', 1930 => 'horse', 1931 => 'sheep', 1932 => 'monkey', 1933 => 'rooster', 1934 => 'dog', 1935 => 'pig');

for %year_signs.kv -> $year, $sign {
    $zodiac = ChineseZodiac.new(DateTime.new(year => $year, month => $month));

    ok $zodiac.sign eq $sign, "$year: $sign";
}

done-testing;
