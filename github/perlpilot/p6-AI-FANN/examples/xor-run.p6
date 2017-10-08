#!/usr/bin/env perl6

use NativeCall;
use AI::FANN::Raw;

my $dir = $*PROGRAM.parent.Str;

my fann $ann = fann_create_from_file("$dir/output/xor_float.net");

my CArray[float] $input = CArray[float].new(-1.Num, 1.Num);

my $calc_out = fann_run($ann, $input);

put "($input[0], $input[1]) -> $calc_out[0]";

fann_destroy($ann);

