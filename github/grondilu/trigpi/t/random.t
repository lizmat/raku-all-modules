use Test;
use TrigPi;

constant N = 1000;
constant scale = N/3;
plan 3*N;
for scale*(.5-rand) xx N {
    is-approx sin(pi*$_), sinPi($_);
    is-approx cos(pi*$_), cosPi($_);
    is-approx cis(pi*$_), cisPi($_);
}
