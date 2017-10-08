#!perl6

use v6;
use Test;
use lib 'lib';
use Number::Denominate;

is denominate(58*60 + 42, :1precision), '59 minutes', 'round up';
is denominate(59*60 + 29, :1precision), '59 minutes', 'round down';
is denominate(59*60 + 42, :1precision), '1 hour', 'round up a unit';

is denominate(60*60*24 + 58*60 + 42, :1precision), '1 day',
    'round up [middle]';
is denominate(60*60*24 + 59*60 + 29, :1precision), '1 day',
    'round down [middle]';
is denominate(60*60*24 + 59*60 + 42, :1precision), '1 day',
    'round up a unit [middle]';

is denominate(60*60*24*7 + 60*60*24*4, :1precision), '2 weeks',
    'round up [highest unit]';
is denominate(60*60*24*7 + 60*60*24*3, :1precision), '1 week',
        'round down [highest unit]';

done-testing;
