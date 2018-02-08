#! /usr/bin/env perl6
use v6;
use Test;

use-ok('ScaleVec::Scale::EqualTemperment');
use ScaleVec::Scale::EqualTemperment;

my ScaleVec::Scale::EqualTemperment $twelve-tet .= new;

is $twelve-tet.step(49), 440, "key 49(A⁴)";
is $twelve-tet.step(37), 220, "key 37(A³)";
is $twelve-tet.step(61), 880, "key 61(A⁵)";
is $twelve-tet.step(40), 261.625565300598|261.625565300599, "key 40(C⁴)";
is $twelve-tet.step(46), 369.994422711634, "key 46(F♯⁴)";
is $twelve-tet.step(43), 311.126983722081, "key 43(D♯⁴)";

done-testing
