use lib <lib>;
use Testo;

plan 7;

is-eqv 1, 1;
is-eqv 1, none 2;
is-eqv 1.0, 1.0;
is-eqv '1', '1';
is-eqv /foo/, /foo/;
is-eqv (1, 2, 3), (1, 2, 3);
is-eqv 1..*, 1..Inf;
