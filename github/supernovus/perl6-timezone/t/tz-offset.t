#!/usr/bin/env perl6

use v6;

use lib './lib';

use Test;
use DateTime::TimeZone;

plan 4;

is tz-offset('+0200'),    7200, 'Explicitly positive offset works';
is tz-offset('-0700'),  -25200, 'Negative offset works';
is tz-offset('0430'),    16200, 'Implicit positive offset works';
is tz-offset('-05:45'), -20700, 'Offset with colon works';
