[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-LibSVM.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-LibSVM)

NAME
====

Algorithm::LibSVM - A Perl 6 bindings for libsvm

SYNOPSIS
========

EXAMPLE 1
---------

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

EXAMPLE 2
---------

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

DESCRIPTION
===========

Algorithm::LibSVM is a Perl 6 bindings for libsvm.

METHODS
-------

### cross-validation

Defined as:

    method cross-validation(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param, Int $nr-fold) returns Array

Conducts `$nr-fold`-fold cross validation and returns predicted values.

### train

Defined as:

    method train(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param) returns Algorithm::LibSVM::Model

Trains a SVM model.

  * `$problem` The instance of Algorithm::LibSVM::Problem.

  * `$param` The instance of Algorithm::LibSVM::Parameter.

### load-problem

Defined as:

    multi method load-problem(\lines) returns Algorithm::LibSVM::Problem
    multi method load-problem(Str $filename) returns Algorithm::LibSVM::Problem

Loads libsvm-format data.

### load-model

Defined as:

    method load-model(Str $filename) returns Algorithm::LibSVM::Model

Loads libsvm model.

### evaluate

Defined as:

    method evaluate(@true-values, @predicted-values) returns Hash

Evaluates the performance of the three metrics (i.e. accuracy, mean squared error and squared correlation coefficient)

  * `@true-values` The array that contains ground-truth values.

  * `@predicted-values` The array that contains predicted values.

### nr-feature

Defined as:

    method nr-feature returns Int:D

Returns the maximum index of all the features.

ROUTINES
--------

### parse-libsvmformat

Defined as:

    sub parse-libsvmformat(Str $text) returns Array is export

Is a helper routine for handling libsvm-format text.

CAUTION
=======

DON'T USE `PRECOMPUTED` KERNEL
------------------------------

As a temporary expedient for [RT130187](https://rt.perl.org/Public/Bug/Display.html?id=130187), I applied the patch programs (e.g. [src/3.22/svm.cpp.patch](src/3.22/svm.cpp.patch)) for the sake of disabling random access of the problematic array.

Sadly to say, those patches drastically increase the complexity of using `PRECOMPUTED` kernel.

SEE ALSO
========

  * libsvm [https://github.com/cjlin1/libsvm](https://github.com/cjlin1/libsvm)

  * RT130187 [https://rt.perl.org/Public/Bug/Display.html?id=130187](https://rt.perl.org/Public/Bug/Display.html?id=130187)

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.
