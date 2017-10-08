use v6;
use NativeCall;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Model;
use Algorithm::LibSVM::Grammar;
use Algorithm::LibSVM::Actions;
use NativeHelpers::Array;

unit class Algorithm::LibSVM;

has Int $.nr-feature;

my constant $library = %?RESOURCES<libraries/svm>.Str;

my sub svm_cross_validation(Algorithm::LibSVM::Problem, Algorithm::LibSVM::Parameter, int32, CArray[num64]) is native($library) { * }
my sub svm_train(Algorithm::LibSVM::Problem, Algorithm::LibSVM::Parameter) returns Algorithm::LibSVM::Model is native($library) { * }
my sub svm_check_parameter(Algorithm::LibSVM::Problem, Algorithm::LibSVM::Parameter) returns Str is native($library) { * }
my sub print_string_stdout(Str) returns Pointer[void] is native($library) { * }
my sub svm_set_print_string_function(&print_func (Str --> Pointer[void])) is native($library) { * }
my sub svm_set_srand(int32) is native($library) { * }

submethod BUILD(Bool :$verbose? = False, Int :$seed = 1) {
    unless $verbose {
        my $f = sub (Str --> Pointer[void]) { Nil };
        svm_set_print_string_function($f);
    }
    svm_set_srand($seed);
}

method cross-validation(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param, Int $nr-fold) returns Array {
    my $target = CArray[num64].new;
    $target[$problem.l] = 0e0; # memory allocation
    svm_cross_validation($problem, $param, $nr-fold, $target);
    copy-to-array($target, $problem.l);
}

method check-parameter(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param) returns Bool {
    my $msg = svm_check_parameter($problem, $param);
    die "$msg" if $msg.defined;
    True
}

method train(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param) returns Algorithm::LibSVM::Model {
    if $param.gamma == 0 && $!nr-feature > 0 {
        $param.gamma((1.0 / $!nr-feature).Num);
    }
    svm_train($problem, $param) if self.check-parameter($problem, $param);
}

multi method load-problem(\lines) returns Algorithm::LibSVM::Problem {
    self!_load-problem(lines)
}

multi method load-problem(Str $filename) returns Algorithm::LibSVM::Problem {
    self!_load-problem($filename.IO.lines)
}

method !_load-problem(\lines) {
    my $prob-y = CArray[num64].new;
    my $prob-x = CArray[Algorithm::LibSVM::Node].new;
    
    my $y-idx = 0;
    for lines -> $line {
        my ($label, $features) = $line.trim.split(/\s+/,2);
        my @feature-list = $features.split(/\s+/);

        my $next = Algorithm::LibSVM::Node.new(index => -1, value => 0e0);
        for @feature-list>>.split(":", :skip-empty).map({ .[0] => .[1] }).sort(-*.key).map({ .key, .value }) -> ($index, $value) {
            $!nr-feature = ($!nr-feature, $index.Int).max;
            $next = Algorithm::LibSVM::Node.new(index => $index.Int, value => $value.Num, next => $next);
        }
        $prob-y[$y-idx] = $label.Num;
        $prob-x[$y-idx] = $next;
        $y-idx++;
    }
    return Algorithm::LibSVM::Problem.new(l => $y-idx, y => $prob-y, x => $prob-x);
}

my sub svm_load_model(Str) returns Algorithm::LibSVM::Model is native($library) { * }

method load-model(Str $filename) returns Algorithm::LibSVM::Model {
    svm_load_model($filename)
}

method evaluate(@true-values, @predicted-values) returns Hash {
    if @true-values.elems != @predicted-values.elems {
        die 'ERROR: @true-values.elem != @predicted-values.elem';
    }
    my ($total-correct, $total-error) = 0, 0;
    my ($sum-p, $sum-t, $sum-pp, $sum-tt, $sum-pt) = 0, 0, 0, 0, 0;
    for @true-values Z @predicted-values -> ($t, $p) {
        $total-correct++ if $p == $t;
        $total-error += ($p - $t) ** 2;
        $sum-p += $p;
        $sum-t += $t;
        $sum-pp += $p ** 2;
        $sum-tt += $t ** 2;
        $sum-pt += $p * $t;
    }

    my Num $num-t = @true-values.elems.Num;
    my Num $accuracy = 100.0 * $total-correct / $num-t;
    my Num $mean-squared-error = $total-error / $num-t;

    my Num $denom =  ($num-t * $sum-pt - $sum-p ** 2) * ($num-t * $sum-pt - $sum-t ** 2);
    my Num $squared-correlation-coefficient
    = do if -1e-20 <= $denom <= 1e-20 {
        Num;
    } else {
        ($num-t * $sum-pt - $sum-p * $sum-t) ** 2 / $denom;
    }
    { acc => $accuracy, mse =>  $mean-squared-error, scc =>  $squared-correlation-coefficient }
}

sub parse-libsvmformat(Str $text) returns Array is export {
    Algorithm::LibSVM::Grammar.parse($text, actions => Algorithm::LibSVM::Actions).made
}

=begin pod

=head1 NAME

Algorithm::LibSVM - A Perl 6 bindings for libsvm

=head1 SYNOPSIS

=head2 EXAMPLE 1

  use Algorithm::LibSVM;
  use Algorithm::LibSVM::Parameter;
  use Algorithm::LibSVM::Problem;
  use Algorithm::LibSVM::Model;

  my $libsvm = Algorithm::LibSVM.new;
  my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                    kernel-type => RBF);
  my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem('heart_scale');
  my @r = $libsvm.cross-validation($problem, $param, 10);
  $libsvm.evaluate($problem.y, @r).say; # {acc => 81.1111111111111, mse => 0.755555555555556, scc => 1.01157627463546}

=head2 EXAMPLE 2

  use Algorithm::LibSVM;
  use Algorithm::LibSVM::Parameter;
  use Algorithm::LibSVM::Problem;
  use Algorithm::LibSVM::Model;

  sub gen-train {
      my $max-x = 1;
      my $min-x = -1;
      my $max-y = 1;
      my $min-y = -1;

      do for ^300 {
         my $x = $min-x + rand * ($max-x - $min-x);
         my $y = $min-y + rand * ($max-y - $min-y);

         my $label = do given $x, $y {
            when ($x - 0.5) ** 2 + ($y - 0.5) ** 2 <= 0.2 {
                   1
            }
            when ($x - -0.5) ** 2 + ($y - -0.5) ** 2 <= 0.2 {
                2
            }
            default { Nil }
      }
      ($label,"1:$x","2:$y") if $label.defined;
    }.sort({ $^a.[0] cmp $^b.[0] })>>.join(" ")
  }

  my Str @train = gen-train;

  my Pair @test = parse-libsvmformat(q:to/END/).head<pairs>.flat;
  1 1:0.5 2:0.5
  END

  my $libsvm = Algorithm::LibSVM.new;
  my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                    kernel-type => LINEAR);
  my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
  my $model = $libsvm.train($problem, $parameter);
  say $model.predict(features => @test)<label> # 1

=head1 DESCRIPTION

Algorithm::LibSVM is a Perl 6 bindings for libsvm.

=head2 METHODS

=head3 cross-validation

Defined as:

       method cross-validation(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param, Int $nr-fold) returns Array

Conducts C<$nr-fold>-fold cross validation and returns predicted values.

=head3 train

Defined as:

        method train(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param) returns Algorithm::LibSVM::Model

Trains a SVM model.

=item C<$problem> The instance of Algorithm::LibSVM::Problem.

=item C<$param> The instance of Algorithm::LibSVM::Parameter.

=head3 load-problem

Defined as:

        multi method load-problem(\lines) returns Algorithm::LibSVM::Problem
        multi method load-problem(Str $filename) returns Algorithm::LibSVM::Problem

Loads libsvm-format data.

=head3 load-model

Defined as:

        method load-model(Str $filename) returns Algorithm::LibSVM::Model

Loads libsvm model.

=head3 evaluate

Defined as:

        method evaluate(@true-values, @predicted-values) returns Hash

Evaluates the performance of the three metrics (i.e. accuracy, mean squared error and squared correlation coefficient)

=item C<@true-values> The array that contains ground-truth values.

=item C<@predicted-values> The array that contains predicted values.

=head3 nr-feature

Defined as:

        method nr-feature returns Int:D

Returns the maximum index of all the features.

=head2 ROUTINES

=head3 parse-libsvmformat

Defined as:

        sub parse-libsvmformat(Str $text) returns Array is export

Is a helper routine for handling libsvm-format text.

=head1 CAUTION

=head2 DON'T USE C<PRECOMPUTED> KERNEL

As a temporary expedient for L<RT130187|https://rt.perl.org/Public/Bug/Display.html?id=130187>, I applied the patch programs (e.g. L<src/3.22/svm.cpp.patch>) for the sake of disabling random access of the problematic array.

Sadly to say, those patches drastically increase the complexity of using C<PRECOMPUTED> kernel.

=head1 SEE ALSO

=item libsvm L<https://github.com/cjlin1/libsvm>

=item RT130187 L<https://rt.perl.org/Public/Bug/Display.html?id=130187>

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
