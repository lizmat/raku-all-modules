use v6;
use Test;
use Algorithm::LBFGS;
use Algorithm::LBFGS::Parameter;

{
    my Algorithm::LBFGS $lbfgs .= new;
    my &evaluate = sub ($instance, $x, $g, $n, $step --> Num) {
        my Num $fx = ($x[0] - 2.0) ** 2 + ($x[1] - 5.0) ** 2;
        $g[0] = 2.0 * $x[0] - 4.0;
        $g[1] = 2.0 * $x[1] - 10.0;
        return $fx;
    };
    my &progress = sub ($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls --> Int) {
        return 0;
    }
    my Algorithm::LBFGS::Parameter $parameter .= new;
    my Num @x0 = [0e0, 0e0];
    lives-ok {
        my @x = $lbfgs.minimize(:@x0, :&evaluate, :$parameter);
    }, "Given the default parameter and an optimizable objective function, then it should return the resulting variables";
}

{
    my Algorithm::LBFGS $lbfgs .= new;
    my &evaluate = sub ($instance, $x, $g, $n, $step --> Num) {
        my Num $fx = ($x[0] - 2.0) ** 2 + ($x[1] - 5.0) ** 2;
        $g[0] = 2.0 * $x[0] - 4.0;
        $g[1] = 2.0 * $x[1] - 10.0;
        return $fx;
    };
    my &progress = sub ($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls --> Int) {
        return 0;
    }
    my Algorithm::LBFGS::Parameter $parameter .= new(linesearch => LBFGS_LINESEARCH_MORETHUENTE);
    my Num @x0 = [0e0, 0e0];
    lives-ok {
        my @x = $lbfgs.minimize(:@x0, :&evaluate, :$parameter);
    }, "Given the default parameter and an optimizable objective function, when linesearch => LBFGS_LINESEARCH_MORETHUENTE, then it should return the resulting variables";
}

{
    my Algorithm::LBFGS $lbfgs .= new;
    my &evaluate = sub ($instance, $x, $g, $n, $step --> Num) {
        my Num $fx = ($x[0] - 2.0) ** 2 + ($x[1] - 5.0) ** 2;
        $g[0] = 2.0 * $x[0] - 4.0;
        $g[1] = 2.0 * $x[1] - 10.0;
        return $fx;
    };
    my &progress = sub ($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls --> Int) {
        return 0;
    }
    my Algorithm::LBFGS::Parameter $parameter .= new(linesearch => LBFGS_LINESEARCH_BACKTRACKING_ARMIJO);
    my Num @x0 = [0e0, 0e0];
    lives-ok {
        my @x = $lbfgs.minimize(:@x0, :&evaluate, :$parameter);
    }, "Given the default parameter and an optimizable objective function, when linesearch => LBFGS_LINESEARCH_BACKTRACKING_ARMIJO, then it should return the resulting variables";
}

{
    my Algorithm::LBFGS $lbfgs .= new;
    my &evaluate = sub ($instance, $x, $g, $n, $step --> Num) {
        my Num $fx = ($x[0] - 2.0) ** 2 + ($x[1] - 5.0) ** 2;
        $g[0] = 2.0 * $x[0] - 4.0;
        $g[1] = 2.0 * $x[1] - 10.0;
        return $fx;
    };
    my &progress = sub ($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls --> Int) {
        return 0;
    }
    my Algorithm::LBFGS::Parameter $parameter .= new(linesearch => LBFGS_LINESEARCH_BACKTRACKING);
    my Num @x0 = [0e0, 0e0];
    lives-ok {
        my @x = $lbfgs.minimize(:@x0, :&evaluate, :$parameter);
    }, "Given the default parameter and an optimizable objective function, when linesearch => LBFGS_LINESEARCH_BACKTRACKING, then it should return the resulting variables";
}

{
    my Algorithm::LBFGS $lbfgs .= new;
    my &evaluate = sub ($instance, $x, $g, $n, $step --> Num) {
        my Num $fx = ($x[0] - 2.0) ** 2 + ($x[1] - 5.0) ** 2;
        $g[0] = 2.0 * $x[0] - 4.0;
        $g[1] = 2.0 * $x[1] - 10.0;
        return $fx;
    };
    my &progress = sub ($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls --> Int) {
        return 0;
    }
    my Algorithm::LBFGS::Parameter $parameter .= new(linesearch => LBFGS_LINESEARCH_BACKTRACKING_STRONG_WOLFE);
    my Num @x0 = [0e0, 0e0];
    lives-ok {
        my @x = $lbfgs.minimize(:@x0, :&evaluate, :$parameter);
    }, "Given the default parameter and an optimizable objective function, when linesearch => LBFGS_LINESEARCH_BACKTRACKING_STRONG_WOLFE, then it should return the resulting variables";
}

subtest {
    my Algorithm::LBFGS $lbfgs .= new;
    my &evaluate = sub ($instance, $x, $g, $n, $step --> Num) {
        my Num $fx = ($x[0] - 2.0) ** 2 + ($x[1] - 5.0) ** 2;
        $g[0] = 2.0 * $x[0] - 4.0;
        $g[1] = 2.0 * $x[1] - 10.0;
        return $fx;
    };
    my &progress = sub ($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls --> Int) {
        return 0;
    }
    my Algorithm::LBFGS::Parameter $parameter .= new(max_iterations => 1);
    my Num @x0 = [0e0, 0e0];
    throws-like { $lbfgs.minimize(:@x0, :&evaluate, :$parameter) }, Exception, message => 'ERROR: LBFGSERR_MAXIMUMITERATION';
}, "Given an optimizable objective function, when the number of max_iterations is insufficient, then it should return LBFGSERR_MAXIMUMITERATION";

# TODO: More tests

done-testing;
