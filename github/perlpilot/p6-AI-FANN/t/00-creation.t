#!/usr/bin/env perl6

use Test;
use AI::FANN::Raw;
use NativeCall;

my @layers = 2,3,5,3,1;
my %default = (
    network_type        => FANN_NETTYPE_LAYER.Int,
    connection_rate     => 1,
);

sub array_match($a,$b) {
    my $success = 1;
    for $a.keys -> $i {
        $success = 0 if $a[$i] != $b[$i];
    }
    return $success;
}

{
    my CArray[uint32] $layers .= new(|@layers);
    my fann $nn = fann_create_standard_array(+@layers, $layers);
    ok $nn, 'fann_create_standard_array';

    my $num-layers = fann_get_num_layers($nn);
    is $num-layers, +@layers, 'fann_get_num_layers';

    my $input-layers = fann_get_num_input($nn);
    is $input-layers, @layers[0], 'fann_get_num_input';

    my $output-layers = fann_get_num_input($nn);
    is $output-layers, @layers[.end], 'fann_get_num_output';

    my $total-neurons = fann_get_total_neurons($nn);
    is $total-neurons, @layers.sum + @layers - 1, 'fann_get_total_neurons';

    # not sure how to calculate the number of connections
    my $total-connections = fann_get_total_connections($nn);
    is $total-connections, 51, 'fann_get_total_connections';

    my $network-type = fann_get_network_type($nn);
    is $network-type, %default<network_type>, 'fann_get_network_type';

    my $connection-rate = fann_get_connection_rate($nn);
    is $connection-rate, %default<connection_rate>, 'fann_get_connection_rate';

    my CArray[uint32] $layers-out = CArray[uint32].allocate($num-layers);
    fann_get_layer_array($nn, $layers-out);
    my $success = array_match(@layers,$layers-out);
    ok $success, 'fann_get_layer_array';

    my CArray[uint32] $bias-out = CArray[uint32].allocate($num-layers);
    fann_get_bias_array($nn, $bias-out);
    ok $bias-out, 'fann_get_bias_array';

    my CArray[fann_connection] $connection-out = CArray[fann_connection].allocate($total-connections);
    fann_get_connection_array($nn, $connection-out);
    ok $connection-out, 'fann_get_connection_array';
}


#{
#    my fann $nn = fann_create_standard(+@layers, @layers);
#    ok $nn, 'fann_create_standard';
#}

{
    my @layers = 3,5,1;
    my CArray[uint32] $layers .= new(|@layers);
    my float $connection-rate = 0.75e0;
    my fann $nn = fann_create_sparse_array($connection-rate, +@layers, $layers);
    ok $nn, 'fann_create_sparse_array';
}

{
    my @layers = 3,7,2;
    my CArray[uint32] $layers .= new(|@layers);
    my fann $nn = fann_create_shortcut_array(+@layers, $layers);
    ok $nn, 'fann_create_shortcut_array';

    my $nn2 = fann_copy($nn);

    ok $nn2, 'fann_copy';
}


done-testing;
