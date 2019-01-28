#!/usr/bin/env perl6
use v6.c;

use Test;
use Zodiac::Chinese;

my $zodiac;
my $month = 2;

my %year_elements = (1984 => 'wood', 1986 => 'fire', 1988 => 'earth', 1990 => 'metal', 1992 => 'water');

for %year_elements.kv -> $year, $element {
    $zodiac = ChineseZodiac.new(DateTime.new(year => $year, month => $month));

    ok $zodiac.element eq $element, "$year: $element";
}

done-testing;
