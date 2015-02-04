use v6;
use Test;
use Math::Tau;

plan 4;

is tau, 2 * pi, 'tau is 2π';
is τ, 2 * pi, 'and so is τ';
is 70 * τ, 140 * pi, 'math works';
is τ + tau + pi, 5 * pi, 'can use both';

done;
