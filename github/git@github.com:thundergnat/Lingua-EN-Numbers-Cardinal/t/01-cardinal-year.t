use v6;
use Test;
use Lingua::EN::Numbers::Cardinal;

plan 15;

is(cardinal-year(2002), 'twenty oh-two');
is(cardinal-year(2007, :oh('ought-') ), 'twenty ought-seven');
is(cardinal-year(2000), 'two thousand');
is(cardinal-year(100),  'one hundred');
is(cardinal-year(2015), 'twenty fifteen');
is(cardinal-year(2525), 'twenty-five twenty-five');
is(cardinal-year(1976), 'nineteen seventy-six');
is(cardinal-year(1900), 'nineteen hundred');
is(cardinal-year(1215), 'twelve fifteen');

is(cardinal-year(1), 'one');
is(cardinal-year(2), 'two');
is(cardinal-year(5), 'five');

is(cardinal-year(301), 'three oh-one');


dies-ok({ cardinal-year(0)     }, 'Dies on out-of-range year');
dies-ok({ cardinal-year(11111) }, 'Dies on out-of-range year');

done-testing();
