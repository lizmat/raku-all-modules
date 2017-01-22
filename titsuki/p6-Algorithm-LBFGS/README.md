[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-LBFGS.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-LBFGS)

NAME
====

Algorithm::LBFGS - A Perl6 bindings for libLBFGS

SYNOPSIS
========

    use Algorithm::LBFGS;
    use Algorithm::LBFGS::Parameter;

    my Algorithm::LBFGS $lbfgs .= new;
    my &evaluate = sub ($instance, $x, $g, $n, $step --> Num) {
       my Num $fx = ($x[0] - 2.0) ** 2 + ($x[1] - 5.0) ** 2;
       $g[0] = 2.0 * $x[0] - 4.0;
       $g[1] = 2.0 * $x[1] - 10.0;
       return $fx;
    };
    my Algorithm::LBFGS::Parameter $parameter .= new;
    my Num @x0 = [0e0, 0e0];
    my @x = $lbfgs.minimize(:@x0, :&evaluate, :$parameter);
    @x.say; # [2e0, 5e0]

DESCRIPTION
===========

Algorithm::LBFGS is a Perl6 bindings for libLBFGS. libLBFGS is a C port of the implementation of Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) method written by Jorge Nocedal.

The L-BFGS method solves the unconstrainted minimization problem,

    minimize F(x), x = (x1, x2, ..., xN),

only if the objective function F(x) and its gradient G(x) are computable.

CONSTRUCTOR
-----------

    my $lbfgs = Algorithm::LBFGS.new;
    my Algorithm::LBFGS $lbfgs .= new; # with type restrictions

METHODS
-------

### minimize(:@x0!, :&evaluate!, :&progress, Algorithm::LBFGS::Parameter :$parameter!) returns Array

    my @x = $lbfgs.minimize(:@x0!, :&evaluate, :&progress, :$parameter); # use &progress callback
    my @x = $lbfgs.minimize(:@x0!, :&evaluate, :$parameter);

Runs the optimization and returns the resulting variables.

`:@x0` is the initial value of the variables.

`:&evaluate` is the callback function. This requires the definition of the objective function F(x) and its gradient G(x).

`:&progress` is the callback function. This gets called on every iteration and can output the internal state of the current iteration.

`:$parameter` is the instance of the `Algorithm::LBFGS::Parameter` class.

#### :&evaluate

The one of the simplest `&evaluate` callback function would be like the following:

    my &evaluate = sub ($instance, $x, $g, $n, $step --> Num) {
       my Num $fx = ($x[0] - 2.0) ** 2 + ($x[1] - 5.0) ** 2; # F(x) = (x0 - 2.0)^2 + (x1 - 5.0)^2

       # G(x) = [∂F(x)/∂x0, ∂F(x)/∂x1]
       $g[0] = 2.0 * $x[0] - 4.0; # ∂F(x)/∂x0 = 2.0 * x0 - 4.0
       $g[1] = 2.0 * $x[1] - 10.0; # ∂F(x)/∂x1 = 2.0 * x1 - 10.0
       return $fx;
    };

  * `$instance` is the user data. (NOTE: NYI in this binder. You must set it as a first argument, but you can't use it in the callback.)

  * `$x` is the current values of variables.

  * `$g` is the current gradient values of variables.

  * `$n` is the number of variables.

  * `$step` is the line-search step used for this iteration.

`&evaluate` requires all of these five arguments in this order.

After writing the definition of the objective function F(x) and its gradient G(x), it requires returning the value of the F(x).

#### :&progress

The one of the simplest `&progress` callback function would be like the following:

    my &progress = sub ($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls --> Int) {
	    "Iteration $k".say;
	    "fx = $fx, x[0] = $x[0], x[1] = $x[1]".say;
	    return 0;
    }

  * `$instance` is the user data. (NOTE: NYI in this binder. You must set it as a first argument, but you can't use it in the callback.)

  * `$x` is the current values of variables.

  * `$g` is the current gradient values of variables.

  * `$fx` is the current value of the objective function.

  * `$xnorm` is the Euclidean norm of the variables.

  * `$gnorm` is the Euclidean norm of the gradients.

  * `$step` is the line-search step used for this iteration.

  * `$n` is the number of variables.

  * `$k` is the iteration count.

  * `$ls` the number of evaluations called for this iteration.

`&progress` requires all of these ten arguments in this order.

#### Algorithm::LBFGS::Parameter :$parameter

Below is the examples of creating a <Algorithm::LBFGS::Parameter> instance:

    my Algorithm::LBFGS::Parameter $parameter .= new; # sets default parameter
    my Algorithm::LBFGS::Parameter $parameter .= new(max_iterations => 100); # sets max_iterations => 100

##### OPTIONS

  * Int `m` is the number of corrections to approximate the inverse hessian matrix.

  * Num `epsilon` is epsilon for convergence test.

  * Int `past` is the distance for delta-based convergence test.

  * Num `delta` is delta for convergence test.

  * Int `max_iterations` is the maximum number of iterations.

  * Int `linesearch` is the line search algorithm. This requires one of `LBFGS_LINESEARCH_DEFAULT`, `LBFGS_LINESEARCH_MORETHUENTE`, `LBFGS_LINESEARCH_BACKTRACKING_ARMIJO`, `LBFGS_LINESEARCH_BACKTRACKING`, `LBFGS_LINESEARCH_BACKTRACKING_WOLFE` and `LBFGS_LINESEARCH_BACKTRACKING_STRONG_WOLFE`. The default value is `LBFGS_LINESEARCH_MORETHUENTE`.

  * Int `max_linesearch` is the maximum number of trials for the line search.

  * Num `min_step` is the minimum step of the line search routine.

  * Num `max_step` is the maximum step of the line search.

  * Num `ftol` is a parameter to control the accuracy of the line search routine.

  * Num `wolfe` is a coefficient for the Wolfe condition.

  * Num `gtol` is a parameter to control the accuracy of the line search routine.

  * Num `xtol` is the machine precision for floating-point values.

  * Num `orthantwise_c` is a coeefficient for the L1 norm of variables.

  * Int `orthantwise_start` is the start index for computing L1 norm of the variables.

  * Int `orthantwise_end` is the end index for computing L1 norm of the variables.

STATUS CODES
------------

TBD

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

Copyright 1990 Jorge Nocedal

Copyright 2007-2010 Naoki Okazaki

libLBFGS by Naoki Okazaki is licensed under the MIT License.

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

SEE ALSO
========

  * libLBFGS [http://www.chokkan.org/software/liblbfgs/index.html](http://www.chokkan.org/software/liblbfgs/index.html)
