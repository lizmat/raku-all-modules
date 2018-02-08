#! /usr/bin/env perl6
use v6;
use Test;

use-ok('ScaleVec::Vectorable');
use ScaleVec::Vectorable;

is pv-to-iv( (0, 2, 4, 5, 7, 9, 11, 12) ),  (2, 2, 1, 2, 2, 2, 1),      "pv-to-iv";
is iv-to-pv( (2, 2, 1, 2, 2, 2, 1) ),       (0, 2, 4, 5, 7, 9, 11, 12), "iv-to-pv";

done-testing
