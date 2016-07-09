use v6;
use lib 'lib';
use Quantum::Collapse;

say (2, 3) eqv     <2 3>; # False
say (2, 3) eqv n<- <2 3>; # True
say [2, 3] eqv @(n<- <2 3>).Array; # True

my @a = <1 2 3>;
my @b = 1, 2, 3;
say @b eqv  n<- @a; # False
say @b eqv (n<- @a).Array; # True
