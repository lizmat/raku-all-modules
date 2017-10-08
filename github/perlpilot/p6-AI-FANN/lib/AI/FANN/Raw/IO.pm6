unit module AI::FANN::Raw::IO;

use NativeCall;
use AI::FANN::Raw::Base;

sub fann_create_from_file(Str) returns fann is export is native(&fannlib) {*}
sub fann_save(fann, Str) returns int32 is export is native(&fannlib) {*}

