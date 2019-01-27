use v6;
use NativeCall;
use lib 'lib';
use Algorithm::LBFGS;

sub lbfgs_evaluate_t($instance, $x, $g, $n, $step) returns Num {
    my Num $fx = 0e0;
    loop (my $i = 0; $i < $n; $i += 2) {
    	my Num $t1 = 1.0e0 - $x[$i];
    	my Num $t2 = 10.0e0 * ($x[$i + 1] - $x[$i] ** 2);
    	$g[$i + 1] = 20.0e0 * $t2;
    	$g[$i] = -2.0 * ($x[$i] * $g[$i+1] + $t1);
    	$fx += $t1 ** 2  + $t2 ** 2;
    }
    return $fx;
}

sub lbfgs_progress_t($instance, $x, $g, $fx, $xnorm, $gnorm, $step, $n, $k, $ls) returns Int {
    "Iteration $k".say;
    "fx = $fx, x[0] = $x[0], x[1] = $x[1]".say;
    return 0;
}

my Algorithm::LBFGS::Parameter $param .= new;
my Algorithm::LBFGS $lbfgs .= new;
my Num @x0;
loop (my $i = 0; $i < 100; $i += 2) {
    @x0[$i] = -1.2e0;
    @x0[$i + 1] = 1.0e0;
}

my @ret = $lbfgs.minimize(:@x0, :evaluate(&lbfgs_evaluate_t), :progress(&lbfgs_progress_t), :parameter($param));
@ret.say;
