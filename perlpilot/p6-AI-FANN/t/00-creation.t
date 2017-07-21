#!/usr/bin/env perl6

use Test;
use AI::FANN::Raw;
use NativeCall;

my @layers = 2,3,1;

{
    my CArray[uint32] $layers = CArray[uint32].new(|@layers);
    my fann $nn = fann_create_standard_array(+@layers, $layers);

    my $num-layers = fann_get_num_layers($nn);
    is $num-layers, +@layers, 'fann_create_standard_array';
}


{
    my fann $nn= fann_create_standard(+@layers, @layers);
    my $num-layers = fann_get_num_layers($nn);
    is $num-layers, +@layers, 'fann_create_standard';
}


done-testing;
