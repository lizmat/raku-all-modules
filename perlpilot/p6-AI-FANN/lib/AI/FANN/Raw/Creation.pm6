
unit module AI::FANN::Raw::Creation;

use NativeCall;
use AI::FANN::Raw::Base;

## http://leenissen.dk/fann/html/files/fann-h.html
## FANN Creation/Execution

#sub fann_create_standard(uint32 $num_layers, ...) returns fann is export is native(&fannlib) {*}
sub fann_create_standard(uint32 $num_layers, *@neurons) returns fann is export {
    my CArray[uint32] $layers = CArray[uint32].new(@neurons);
    return fann_create_standard_array($num_layers, $layers);
}

sub fann_create_standard_array(uint32 $num_layers, CArray[int32] $layers is rw ) returns fann is export is native(&fannlib) {*}

sub fann_create_sparse(float $connection_rate, uint32 $num_layers, *@neurons) returns fann is export {
    my CArray[uint32] $layers = CArray[uint32].new(@neurons);
    return fann_create_sparse_array($connection_rate, $num_layers, $layers);
}
sub fann_create_sparse_array(float $connection_rate, uint32 $num_layers, CArray[int32] $layers is rw ) returns fann is export is native(&fannlib) {*}
sub fann_create_shortcut(uint32 $num_layers, *@neurons) returns fann is export {
    my CArray[uint32] $layers = CArray[uint32].new(@neurons);
    return fann_create_shortcut_array($num_layers, $layers);
}
sub fann_create_shortcut_array(uint32 $num_layers, CArray[int32] $layers is rw ) returns fann is export is native(&fannlib) {*}
sub fann_destroy(fann) is export is native(&fannlib) {*}
sub fann_copy(fann) returns fann is export is native(&fannlib) {*}
sub fann_run(fann, float is rw) returns fann is export is native(&fannlib) {*}
sub fann_randomize_weights(fann, float, float) is export is native(&fannlib) {*}
sub fann_init_weights(fann, fann_train_data) is export is native(&fannlib) {*}

sub fann_print_connections(fann) is export is native(&fannlib) {*}
sub fann_print_parameters(fann) is export is native(&fannlib) {*}

sub fann_get_num_input(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_get_num_output(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_get_total_neurons(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_get_total_connections(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_get_network_type(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_get_connection_rate(fann) returns float is export is native(&fannlib) {*}
sub fann_get_num_layers(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_get_layer_array(fann, uint32 is rw) is export is native(&fannlib) {*}
sub fann_get_bias_array(fann, uint32 is rw) is export is native(&fannlib) {*}
sub fann_get_connection_array(fann, fann_connection is rw) is export is native(&fannlib) {*}

sub fann_set_weight_array(fann, fann_connection, uint32) is export is native(&fannlib) {*}
sub fann_set_weight(fann, uint32, uint32, float) is export is native(&fannlib) {*}
sub fann_set_user_data(fann, Pointer) is export is native(&fannlib) {*}
sub fann_get_user_data(fann) returns Pointer[void] is export is native(&fannlib) {*}

# not found in my version of FANN
#sub fann_get_decimal_point(fann) returns uint32 is export is native(&fannlib) {*}
#sub fann_get_multiplier(fann) returns uint32 is export is native(&fannlib) {*}

