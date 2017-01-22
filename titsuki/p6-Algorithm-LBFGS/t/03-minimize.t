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
    my @x = $lbfgs.minimize(:@x0, :&evaluate, :$parameter);
    is @x, [2e0, 5e0], "Given the default parameter and fx = (x1 - 2)^2 + (x2 - 5)^2, then it should return [2e0,5e0]";
}

done-testing;
