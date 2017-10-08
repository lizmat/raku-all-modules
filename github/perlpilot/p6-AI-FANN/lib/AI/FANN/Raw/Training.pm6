unit module AI::FANN::Raw::Training;

use NativeCall;
use AI::FANN::Raw::Base;


constant fann_errorfunc is export = int32;
enum fann_errorfunc_enum is export «
    FANN_ERRORFUNC_LINEAR
    FANN_ERRORFUNC_TANH
»;

constant fann_stopfunc is export = int32;
enum fann_stopfunc_enum is export «
    FANN_STOPFUNC_MSE
    FANN_STOPFUNC_BIT
»;

## http://leenissen.dk/fann/html/files/fann_train-h.html
## FANN Training

sub fann_train(fann, fann_type is rw, fann_type is rw) is export is native(&fannlib) {*}
sub fann_test(fann, fann_type is rw, fann_type is rw) is export is native(&fannlib) {*}
sub fann_get_MSE(fann) returns float is export is native(&fannlib) {*}
sub fann_get_bit_fail(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_reset_MSE(fann) is export is native(&fannlib) {*}

sub fann_train_on_data(fann, fann_train_data, uint32, uint32, float) is export is native(&fannlib) {*}
sub fann_train_on_file(fann, Str, uint32, uint32, float) is export is native(&fannlib) {*}
sub fann_train_epoch(fann, fann_train_data) is export is native(&fannlib) {*}
sub fann_test_data(fann, fann_train_data) is export is native(&fannlib) {*}

## Training Data Manipulation

sub fann_read_train_from_file(Str) returns fann_train_data is export is native(&fannlib) {*}
sub fann_create_train(uint32, uint32, uint32) returns fann_train_data is export is native(&fannlib) {*}
sub fann_train_data(uint32, uint32, uint32, & (uint32, uint32,uint32,fann_type)) returns fann_train_data is export is native(&fannlib) {*}

# sub fann_destroy_train(fann_train_data) is export is native(&fannlib) {*}
sub fann_shuffle_train_data(fann_train_data) is export is native(&fannlib) {*}
sub fann_scale_train(fann,fann_train_data) is export is native(&fannlib) {*}
sub fann_descale_train(fann,fann_train_data) is export is native(&fannlib) {*}
sub fann_set_input_scaling_params(fann, fann_train_data, float, float) returns int32 is export is native(&fannlib) {*}
sub fann_set_output_scaling_params(fann, fann_train_data, float, float) returns int32 is export is native(&fannlib) {*}
sub fann_set_scaling_params(fann, fann_train_data, float, float, float, float) returns int32 is export is native(&fannlib) {*}
sub fann_clear_scaling_params(fann) returns int32 is export is native(&fannlib) {*}

sub fann_scale_input(fann, fann_type is rw) is export is native(&fannlib) {*}
sub fann_scale_output(fann, fann_type is rw) is export is native(&fannlib) {*}
sub fann_descale_input(fann, fann_type is rw) is export is native(&fannlib) {*}
sub fann_descale_output(fann, fann_type is rw) is export is native(&fannlib) {*}
sub fann_scale_input_train_data(fann_train_data, fann_type, fann_type is rw) is export is native(&fannlib) {*}
sub fann_scale_output_train_data(fann_train_data, fann_type, fann_type is rw) is export is native(&fannlib) {*}
sub fann_scale_train_data(fann_train_data, fann_type, fann_type is rw) is export is native(&fannlib) {*}
sub fann_merge_train_data(fann_train_data, fann_train_data) is export is native(&fannlib) {*}
sub fann_duplicate_train_data(fann_train_data) returns fann_train_data is export is native(&fannlib) {*}
sub fann_subset_train_data(fann_train_data, uint32, uint32) returns fann_train_data is export is native(&fannlib) {*}
sub fann_length_train_data(fann_train_data) returns uint32 is export is native(&fannlib) {*}
sub fann_num_input_train_data(fann_train_data) returns uint32 is export is native(&fannlib) {*}
sub fann_num_output_train_data(fann_train_data) returns uint32 is export is native(&fannlib) {*}
sub fann_save_train(fann_train_data, Str) returns uint32 is export is native(&fannlib) {*}
sub fann_save_train_to_fixed(fann_train_data, Str, uint32) returns uint32 is export is native(&fannlib) {*}

sub fann_get_training_algorithm(fann) returns fann_train is export is native(&fannlib) {*}
sub fann_set_training_algorithm(fann, fann_train) is export is native(&fannlib) {*}
sub fann_get_learning_rate(fann) returns float is export is native(&fannlib) {*}
sub fann_set_learning_rate(fann, float) is export is native(&fannlib) {*}
sub fann_get_learning_momentum(fann) returns float is export is native(&fannlib) {*}
sub fann_set_learning_momentum(fann, float) is export is native(&fannlib) {*}
sub fann_get_activation_function(fann, int32, int32) returns fann_activationfunc is export is native(&fannlib) {*}
sub fann_set_activation_function(fann, fann_activationfunc, int32, int32) returns fann_activationfunc is export is native(&fannlib) {*}

sub fann_set_activation_function_layer(fann, fann_activationfunc, int32) is export is native(&fannlib) {*}
sub fann_set_activation_function_hidden(fann, fann_activationfunc) is export is native(&fannlib) {*}
sub fann_set_activation_function_output(fann, fann_activationfunc) is export is native(&fannlib) {*}

sub fann_get_activation_steepness(fann, int32, int32) returns fann_type is export is native(&fannlib) {*}
sub fann_set_activation_steepness(fann, fann_type, int32, int32) is export is native(&fannlib) {*}
sub fann_set_activation_steepness_layer(fann, fann_type, int32) is export is native(&fannlib) {*}
sub fann_set_activation_steepness_hidden(fann, fann_type) is export is native(&fannlib) {*}
sub fann_set_activation_steepness_output(fann, fann_type) is export is native(&fannlib) {*}

sub fann_get_train_error_function(fann) returns fann_errorfunc is export is native(&fannlib) {*}
sub fann_set_train_error_function(fann, fann_errorfunc) is export is native(&fannlib) {*}

sub fann_get_train_stop_function(fann) returns fann_stopfunc is export is native(&fannlib) {*}
sub fann_set_train_stop_function(fann, fann_stopfunc) is export is native(&fannlib) {*}

sub fann_get_bit_fail_limit(fann) returns fann_type is export is native(&fannlib) {*}
sub fann_set_bit_fail_limit(fann, fann_type) is export is native(&fannlib) {*}

#sub fann_set_callback(fann, fann_callback) is export is native(&fannlib) {*}       # TODO

sub fann_get_quickprop_decay(fann) returns float is export is native(&fannlib) {*}
sub fann_set_quickprop_decay(fann, float) is export is native(&fannlib) {*}

sub fann_get_quickprop_mu(fann) returns float is export is native(&fannlib) {*}
sub fann_set_quickprop_mu(fann, float) is export is native(&fannlib) {*}
sub fann_get_rprop_increase_factor(fann) returns float is export is native(&fannlib) {*}
sub fann_set_rprop_increase_factor(fann, float) is export is native(&fannlib) {*}

sub fann_get_rprop_decrease_factor(fann) returns float is export is native(&fannlib) {*}
sub fann_set_rprop_decrease_factor(fann, float) is export is native(&fannlib) {*}

sub fann_get_rprop_delta_min(fann) returns float is export is native(&fannlib) {*}
sub fann_set_rprop_delta_min(fann, float) is export is native(&fannlib) {*}

sub fann_get_rprop_delta_max(fann) returns float is export is native(&fannlib) {*}
sub fann_set_rprop_delta_max(fann, float) is export is native(&fannlib) {*}

sub fann_get_rprop_delta_zero(fann) returns float is export is native(&fannlib) {*}
sub fann_set_rprop_delta_zero(fann, float) is export is native(&fannlib) {*}

sub fann_get_sarprop_weight_decay_shift(fann) returns float is export is native(&fannlib) {*}
sub fann_set_sarprop_weight_decay_shift(fann, float) is export is native(&fannlib) {*}

sub fann_get_sarprop_step_error_threshold_factor(fann) returns float is export is native(&fannlib) {*}
sub fann_set_sarprop_step_error_threshold_factor(fann, float) is export is native(&fannlib) {*}

sub fann_get_sarprop_step_error_shift(fann) returns float is export is native(&fannlib) {*}
sub fann_set_sarprop_step_error_shift(fann, float) is export is native(&fannlib) {*}

sub fann_get_sarprop_temperature(fann) returns float is export is native(&fannlib) {*}
sub fann_set_sarprop_temperature(fann, float) is export is native(&fannlib) {*}
