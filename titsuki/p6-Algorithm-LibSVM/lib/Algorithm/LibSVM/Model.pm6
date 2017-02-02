use v6;
use NativeHelpers::Array;
use NativeCall;
use Algorithm::LibSVM::Node;
use Algorithm::LibSVM::Parameter;

unit class Algorithm::LibSVM::Model is export is repr('CPointer'); 

my constant $library = %?RESOURCES<libraries/svm>.Str;

my sub svm_get_svm_type(Algorithm::LibSVM::Model) returns int32 is native($library) { * }
my sub svm_get_nr_class(Algorithm::LibSVM::Model) returns int32 is native($library) { * }
my sub svm_get_labels(Algorithm::LibSVM::Model, CArray[int32]) is native($library) { * }
my sub svm_get_sv_indices(Algorithm::LibSVM::Model, CArray[int32]) is native($library) { * }
my sub svm_get_nr_sv(Algorithm::LibSVM::Model) returns int32 is native($library) { * }
my sub svm_get_svr_probability(Algorithm::LibSVM::Model) returns num64 is native($library) { * }
my sub svm_predict_values(Algorithm::LibSVM::Model, Algorithm::LibSVM::Node, CArray[num64]) returns num64 is native($library) { * }
my sub svm_predict(Algorithm::LibSVM::Model, Algorithm::LibSVM::Node) returns num64 is native($library) { * }
my sub svm_predict_probability(Algorithm::LibSVM::Model, Algorithm::LibSVM::Node, CArray[num64]) returns num64 is native($library) { * }
my sub svm_free_model_content(Algorithm::LibSVM::Model) is native($library) { * }
my sub svm_free_and_destroy_model(Algorithm::LibSVM::Model) is native($library) { * }
my sub svm_check_probability_model(Algorithm::LibSVM::Model) returns int32 is native($library) { * }

sub svm_save_model(Str, Algorithm::LibSVM::Model) is native($library) is export { * }

method save(Str $filename) {
    svm_save_model($filename, self)
}

method svm-type returns SVMType {
    SVMType(svm_get_svm_type(self))
}

method nr-class returns Int:D {
    svm_get_nr_class(self)
}

method labels returns Array {
    my $labels = CArray[int32].new;
    $labels[self.nr-class - 1] = 0; # allocate memory
    svm_get_labels(self, $labels);
    copy-to-array($labels, self.nr-class);
}

method sv-indices returns Array {
    my $indices = CArray[int32].new;
    $indices[self.nr-sv - 1] = 0; # allocate memory
    svm_get_sv_indices(self, $indices);
    copy-to-array($indices, self.nr-sv);
}

method nr-sv returns Int:D {
    svm_get_nr_sv(self)
}

method svr-probability returns Num:D {
    svm_get_svr_probability(self)
}

method !make-node-linked-list(:@features) returns Algorithm::LibSVM::Node {
    my Algorithm::LibSVM::Node $next .= new(index => -1, value => 0e0);
    for @features.sort({ $^b.key <=> $^a.key }) {
        $next = Algorithm::LibSVM::Node.new(index => .key, value => .value, next => $next);
    }
    $next;
}

method predict(:@features where Positional[Pair]|Array[Pair], Bool :$probability, Bool :$decision-values) returns Hash {
    my %result;
    if $probability and self.check-probability-model {
        my $prob-estimates = CArray[num64].new;
        $prob-estimates[self.nr-class] = 0e0;
        my $label = svm_predict_probability(self, self!make-node-linked-list(:@features), $prob-estimates);
        my @prob-estimates = copy-to-array($prob-estimates, self.nr-class);
        %result<label> = $label;
        %result<prob-estimates> = @prob-estimates
    }
    if $decision-values {
        my $dec-values = CArray[num64].new;
        $dec-values[self.nr-class * (self.nr-class - 1) div 2] = 0e0;
        my $label = svm_predict_values(self, self!make-node-linked-list(:@features), $dec-values);
        my @dec-values = copy-to-array($dec-values, self.nr-class * (self.nr-class - 1) div 2);
        %result<label> = $label;
        %result<decision-values> = @dec-values;
    }

    if not $probability and not $decision-values {
        %result<label> = svm_predict(self, self!make-node-linked-list(:@features));
    }
    %result;
}

method check-probability-model returns Bool {
    my $ok = Bool(svm_check_probability_model(self));
    if not $ok {
        die "ERROR: Given model cannot compute probability.";
    }
    $ok;
}

submethod DESTROY {
    svm_free_and_destroy_model(self)
}

=begin pod

=head1 NAME

Algorithm::LibSVM::Model - A Perl 6 Algorithm::LibSVM::Model class

=head1 SYNOPSIS

  use Algorithm::LibSVM::Model;

=head1 DESCRIPTION

Algorithm::LibSVM::Model is a Perl 6 Algorithm::LibSVM::Model class

=head2 METHODS

=head3 save

Defined as:

        method save(Str $filename)

Saves the model to the file C<$filename>.

=head3 svm-type

Defined as:

        method svm-type returns SVMType

Returns the C<SVMType> object.

=head3 nr-class

Defined as:

        method nr-class returns Int:D

Returns the number of the classes.

=head3 labels

Defined as:

        method labels returns Array

Returns the labels.

=head3 sv-indices

Defined as:

        method sv-indices returns Array

Returns the indices of the support vectors.

=head3 nr-sv

Defined as:

        method nr-sv returns Int:D

Returns the number of the support vectors.

=head3 svr-probability

Defined as:

        method svr-probability returns Num:D

Returns the probability predicted by support vector regression.

=head3 predict

Defined as:

        method predict(Pair :@features, Bool :$probability, Bool :$decision-values) returns Hash

Conducts the prediction and returns its results.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
