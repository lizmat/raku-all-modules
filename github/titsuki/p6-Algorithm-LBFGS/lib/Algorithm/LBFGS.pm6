use v6;

unit class Algorithm::LBFGS;

use NativeCall;
use Algorithm::LBFGS::Parameter;
use Algorithm::LBFGS::Status;
use NativeHelpers::Array;

my constant $library = %?RESOURCES<libraries/lbfgs>.Str;
my constant ptrsize is export = nativesizeof(Pointer);
my constant lbfgsfloatval_t is export = ptrsize == 8 ?? num64 !! num32;

# Line search algorithms.
enum SOLVER is export (
    # The default algorithm (MoreThuente method). 
    LBFGS_LINESEARCH_DEFAULT => 0,
    
    # MoreThuente method proposd by More and Thuente. 
    LBFGS_LINESEARCH_MORETHUENTE => 0,
    
    # Backtracking method with the Armijo condition.
    # The backtracking method finds the step length such that it satisfies
    # the sufficient decrease (Armijo) condition,
    # - f(x + a * d) <= f(x) + lbfgs_parameter_t::ftol * a * g(x)^T d,
    # where x is the current point, d is the current search direction, and
    # a is the step length.
    LBFGS_LINESEARCH_BACKTRACKING_ARMIJO => 1,
    
    # The backtracking method with the defualt (regular Wolfe) condition. 
    LBFGS_LINESEARCH_BACKTRACKING => 2,
    
    # Backtracking method with regular Wolfe condition.
    # The backtracking method finds the step length such that it satisfies
    # both the Armijo condition (LBFGS_LINESEARCH_BACKTRACKING_ARMIJO)
    # and the curvature condition,
    # - g(x + a * d)^T d >= lbfgs_parameter_t::wolfe * g(x)^T d,
    # where x is the current point, d is the current search direction, and
    # a is the step length.
    LBFGS_LINESEARCH_BACKTRACKING_WOLFE => 2,
    
    # Backtracking method with strong Wolfe condition.
    # The backtracking method finds the step length such that it satisfies
    # both the Armijo condition (LBFGS_LINESEARCH_BACKTRACKING_ARMIJO)
    # and the following condition,
    # - |g(x + a * d)^T d| <= lbfgs_parameter_t::wolfe * |g(x)^T d|,
    # where x is the current point, d is the current search direction, and
    # a is the step length.
    LBFGS_LINESEARCH_BACKTRACKING_STRONG_WOLFE => 3,
);

has CArray[lbfgsfloatval_t] $!x0;

my sub lbfgs(int32,
             CArray[lbfgsfloatval_t], Pointer[lbfgsfloatval_t],
             &lbfgs_evaluate_t (
                 Pointer[void],
                 CArray[lbfgsfloatval_t],
                 CArray[lbfgsfloatval_t],
                 int32,
                 num64
    	             --> lbfgsfloatval_t),
             &lbfgs_progress_t (
                 Pointer[void],
                 CArray[lbfgsfloatval_t],
                 CArray[lbfgsfloatval_t],
                 lbfgsfloatval_t,
                 lbfgsfloatval_t,
                 lbfgsfloatval_t,
                 lbfgsfloatval_t,
                 int32,
                 int32,
                 int32
   	                 --> int32),
             Pointer[void], Algorithm::LBFGS::Parameter) returns int32 is native($library) is export { * }

method minimize(Num :@x0!,
   	            :&evaluate!,
   	            :&progress,
  	            Algorithm::LBFGS::Parameter :$parameter!) returns Array {
    my $instance = Pointer[void].new;
    $!x0 = lbfgs_malloc(@x0.elems);
    $!x0[$_] = @x0[$_] for ^@x0.elems;
    my $fx = Pointer[lbfgsfloatval_t].new;
    my $ret = lbfgs(@x0.elems, $!x0, $fx, &evaluate, &progress // sub ($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls --> Int) { 0 }, $instance, $parameter);
    if STATUS($ret) == LBFGS_SUCCESS|LBFGS_CONVERGENCE {
        return copy-to-array($!x0, @x0.elems);
    } else {
        die "ERROR: " ~ STATUS($ret);
    }
}

my sub lbfgs_malloc(int32) returns CArray[lbfgsfloatval_t] is native($library) is export { * }
my sub lbfgs_free(CArray[lbfgsfloatval_t]) is native($library) is export { * }

submethod DESTROY {
    lbfgs_free($!x0)
}

=begin pod

=head1 NAME

Algorithm::LBFGS - A Perl6 bindings for libLBFGS

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Algorithm::LBFGS is a Perl6 bindings for libLBFGS.
libLBFGS is a C port of the implementation of Limited-memory Broyden-Fletcher-Goldfarb-Shanno (L-BFGS) method written by Jorge Nocedal.

The L-BFGS method solves the unconstrainted minimization problem,

    minimize F(x), x = (x1, x2, ..., xN),

only if the objective function F(x) and its gradient G(x) are computable.
    
=head2 CONSTRUCTOR

       my $lbfgs = Algorithm::LBFGS.new;
       my Algorithm::LBFGS $lbfgs .= new; # with type restrictions

=head2 METHODS

=head3 minimize(:@x0!, :&evaluate!, :&progress, Algorithm::LBFGS::Parameter :$parameter!) returns Array

       my @x = $lbfgs.minimize(:@x0!, :&evaluate, :&progress, :$parameter); # use &progress callback
       my @x = $lbfgs.minimize(:@x0!, :&evaluate, :$parameter);

Runs the optimization and returns the resulting variables.

C<:@x0> is the initial value of the variables.

C<:&evaluate> is the callback function. This requires the definition of the objective function F(x) and its gradient G(x).

C<:&progress> is the callback function. This gets called on every iteration and can output the internal state of the current iteration.

C<:$parameter> is the instance of the C<Algorithm::LBFGS::Parameter> class.

=head4 :&evaluate

The one of the simplest C<&evaluate> callback function would be like the following:

  my &evaluate = sub ($instance, $x, $g, $n, $step --> Num) {
     my Num $fx = ($x[0] - 2.0) ** 2 + ($x[1] - 5.0) ** 2; # F(x) = (x0 - 2.0)^2 + (x1 - 5.0)^2

     # G(x) = [∂F(x)/∂x0, ∂F(x)/∂x1]
     $g[0] = 2.0 * $x[0] - 4.0; # ∂F(x)/∂x0 = 2.0 * x0 - 4.0
     $g[1] = 2.0 * $x[1] - 10.0; # ∂F(x)/∂x1 = 2.0 * x1 - 10.0
     return $fx;
  };

=item C<$instance> is the user data. (NOTE: NYI in this binder. You must set it as a first argument, but you can't use it in the callback.)

=item C<$x> is the current values of variables.

=item C<$g> is the current gradient values of variables.

=item C<$n> is the number of variables.

=item C<$step> is the line-search step used for this iteration.

C<&evaluate> requires all of these five arguments in this order.

After writing the definition of the objective function F(x) and its gradient G(x), it requires returning the value of the F(x).

=head4 :&progress

The one of the simplest C<&progress> callback function would be like the following:

    my &progress = sub ($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls --> Int) {
    	"Iteration $k".say;
    	"fx = $fx, x[0] = $x[0], x[1] = $x[1]".say;
    	return 0;
    }

=item C<$instance> is the user data. (NOTE: NYI in this binder. You must set it as a first argument, but you can't use it in the callback.)

=item C<$x> is the current values of variables.

=item C<$g> is the current gradient values of variables.

=item C<$fx> is the current value of the objective function.

=item C<$xnorm> is the Euclidean norm of the variables.

=item C<$gnorm> is the Euclidean norm of the gradients.

=item C<$step> is the line-search step used for this iteration.

=item C<$n> is the number of variables.

=item C<$k> is the iteration count.

=item C<$ls> the number of evaluations called for this iteration.

C<&progress> requires all of these ten arguments in this order.

=head4 Algorithm::LBFGS::Parameter :$parameter

Below is the examples of creating a <Algorithm::LBFGS::Parameter> instance:

       my Algorithm::LBFGS::Parameter $parameter .= new; # sets default parameter
       my Algorithm::LBFGS::Parameter $parameter .= new(max_iterations => 100); # sets max_iterations => 100

=head5 OPTIONS
       
=item Int C<m> is the number of corrections to approximate the inverse hessian matrix.

=item Num C<epsilon> is epsilon for convergence test.

=item Int C<past> is the distance for delta-based convergence test.

=item Num C<delta> is delta for convergence test.

=item Int C<max_iterations> is the maximum number of iterations.

=item Int C<linesearch> is the line search algorithm. This requires one of C<LBFGS_LINESEARCH_DEFAULT>, C<LBFGS_LINESEARCH_MORETHUENTE>, C<LBFGS_LINESEARCH_BACKTRACKING_ARMIJO>,
C<LBFGS_LINESEARCH_BACKTRACKING>, C<LBFGS_LINESEARCH_BACKTRACKING_WOLFE> and C<LBFGS_LINESEARCH_BACKTRACKING_STRONG_WOLFE>. The default value is C<LBFGS_LINESEARCH_MORETHUENTE>.

=item Int C<max_linesearch> is the maximum number of trials for the line search.

=item Num C<min_step> is the minimum step of the line search routine.

=item Num C<max_step> is the maximum step of the line search.

=item Num C<ftol> is a parameter to control the accuracy of the line search routine.

=item Num C<wolfe> is a coefficient for the Wolfe condition.

=item Num C<gtol> is a parameter to control the accuracy of the line search routine.

=item Num C<xtol> is the machine precision for floating-point values.

=item Num C<orthantwise_c> is a coeefficient for the L1 norm of variables.

=item Int C<orthantwise_start> is the start index for computing L1 norm of the variables.

=item Int C<orthantwise_end> is the end index for computing L1 norm of the variables.

=head2 STATUS CODES

TBD

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

Copyright 1990 Jorge Nocedal

Copyright 2007-2010 Naoki Okazaki

libLBFGS by Naoki Okazaki is licensed under the MIT License.

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

=head1 SEE ALSO

=item libLBFGS L<http://www.chokkan.org/software/liblbfgs/index.html>

=end pod
