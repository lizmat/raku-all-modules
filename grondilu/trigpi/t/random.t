use Test;
use TrigPi;

constant N = 1000;
constant scale = N/10;
plan 2*N;
for scale*(.5-rand) xx N {
    is-approx sin(pi*$_), sinPi($_);
    is-approx cos(pi*$_), cosPi($_);
}
