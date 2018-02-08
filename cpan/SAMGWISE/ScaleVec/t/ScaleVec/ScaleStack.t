#! /usr/bin/env perl6
use v6;
use Test;

use-ok('ScaleVec::Scale::Stack');
use ScaleVec::Scale::Stack;
use ScaleVec;
use ScaleVec::Vectorable;

my @major-interval-vector  = 2, 2, 1, 2, 2, 2, 1;
my ScaleVec    $major      .= new( :vector( iv-to-pv @major-interval-vector ) );
my ScaleVec    $to-midi    .= new( :vector(60, 61) );
my ScaleVec::Scale::Stack         $out-stack  .= new( :scales($major, $to-midi) );

is so $out-stack, True, "Instantiate ScaleVec::Scale::Stack OK";

is $out-stack.step(0),   60,  "Step   0 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(1),   62,  "Step   1 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(-1),  59,  "Step  -1 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(2),   64,  "Step   2 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(-2),  57,  "Step  -2 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(3),   65,  "Step   3 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(-3),  55,  "Step  -3 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(7),   72,  "Step   7 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(-7),  48,  "Step  -7 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(8),   74,  "Step   8 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(-8),  47,  "Step  -8 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(14),  84,  "Step  14 for ScaleVec::Scale::Stack of major -> to-midi";
is $out-stack.step(-14), 36,  "Step -14 for ScaleVec::Scale::Stack of major -> to-midi";

done-testing;
