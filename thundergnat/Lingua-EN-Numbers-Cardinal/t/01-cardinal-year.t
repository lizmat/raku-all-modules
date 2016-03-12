use v6;
use Test;
use Lingua::EN::Numbers::Cardinal;

plan 8;

is(cardinal-year(2002), 'twenty ought-two');
is(cardinal-year(2000), 'two thousand');
is(cardinal-year(100),  'one hundred');
is(cardinal-year(2015), 'twenty fifteen');
is(cardinal-year(2525), 'twenty-five twenty-five');
is(cardinal-year(1976), 'nineteen seventy-six');
is(cardinal-year(1900), 'nineteen hundred');
is(cardinal-year(1215), 'twelve fifteen');

done-testing();
