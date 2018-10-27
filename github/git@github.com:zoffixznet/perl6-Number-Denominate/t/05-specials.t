#!perl6

use v6;
use Test;
use lib 'lib';
use Number::Denominate;

lives-ok { denominate $_, :1precision for 697271 .. 697525 },
    'potential division by zero errors';

done-testing;
