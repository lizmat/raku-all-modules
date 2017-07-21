#!/usr/bin/env perl6

use AI::FANN::Raw;

my $dir = $*PROGRAM.parent.Str;

my $num_input = 2;
my $num_output = 1;
my $num_layers = 3;
my $num_neurons_hidden = 3;
my num32 $desired_error = 0.001.Num;
my uint32 $max_epochs = 500000;
my uint32 $epochs_between_reports = 1000;

my fann $ann = fann_create_standard($num_layers, $num_input, $num_neurons_hidden, $num_output);
fann_set_activation_function_hidden($ann, FANN_SIGMOID_SYMMETRIC);
fann_set_activation_function_output($ann, FANN_SIGMOID_SYMMETRIC);

fann_train_on_file($ann, "$dir/data/xor.data", $max_epochs, $epochs_between_reports, $desired_error);

fann_save($ann, "$dir/output/xor_float.net");

fann_destroy($ann);

