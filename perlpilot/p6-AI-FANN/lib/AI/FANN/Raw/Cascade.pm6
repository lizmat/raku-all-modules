unit module AI::FANN::Raw::Cascade;

use NativeCall;
use AI::FANN::Raw::Base;

sub fann_cascadetrain_on_data( fann, fann_train_data, uint32, uint32, float) is export is native(&fannlib) {*}
sub fann_cascadetrain_on_file( fann, Str, uint32, uint32, float) is export is native(&fannlib) {*}

sub fann_get_cascade_output_change_function(fann) returns float is export is native(&fannlib) {*}
sub fann_set_cascade_output_change_function(fann, float) is export is native(&fannlib) {*}

sub fann_get_cascade_output_stagnation_epochs(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_set_cascade_output_stagnation_epochs(fann, uint32) is export is native(&fannlib) {*}
sub fann_get_cascade_candidate_change_function(fann) returns float is export is native(&fannlib) {*}
sub fann_set_cascade_candidate_change_function(fann, float) is export is native(&fannlib) {*}
sub fann_get_cascade_candidate_stagnation_epochs(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_set_cascade_candidate_stagnation_epochs(fann, uint32) is export is native(&fannlib) {*}
sub fann_get_cascade_weight_multiplier(fann) returns fann_type is export is native(&fannlib) {*}
sub fann_set_cascade_weight_multiplier(fann, fann_type) is export is native(&fannlib) {*}
sub fann_get_cascade_candidate_limit(fann) returns fann_type is export is native(&fannlib) {*}
sub fann_set_cascade_candidate_limit(fann, fann_type) is export is native(&fannlib) {*}
sub fann_get_cascade_max_out_epochs(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_set_cascade_max_out_epochs(fann, uint32) is export is native(&fannlib) {*}
sub fann_get_cascade_min_out_epochs(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_set_cascade_min_out_epochs(fann, uint32) is export is native(&fannlib) {*}

sub fann_get_cascade_max_cand_epochs(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_set_cascade_max_cand_epochs(fann, uint32) is export is native(&fannlib) {*}
sub fann_get_cascade_min_cand_epochs(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_set_cascade_min_cand_epochs(fann, uint32) is export is native(&fannlib) {*}


sub fann_get_cascade_num_candidates(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_get_cascade_activation_functions_count(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_get_cascade_activation_functions(fann) returns fann_activationfunc is export is native(&fannlib) {*}
sub fann_set_cascade_activation_functions(fann, fann_activationfunc, uint32) is export is native(&fannlib) {*}

sub fann_get_cascade_activation_steepness_count(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_get_cascade_activation_steepness(fann) returns fann_type is export is native(&fannlib) {*}
sub fann_set_cascade_activation_steepness(fann, fann_type, uint32) is export is native(&fannlib) {*}

sub fann_get_cascade_num_candidate_groups(fann) returns uint32 is export is native(&fannlib) {*}
sub fann_set_cascade_num_candidate_groups(fann, uint32) is export is native(&fannlib) {*}
