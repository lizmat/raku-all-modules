use v6;
use Test;
use Algorithm::LBFGS;

lives-ok { my Algorithm::LBFGS $lbfgs .= new; }, "Algorithm::LBFGS.new requires no arguments";

done-testing;
