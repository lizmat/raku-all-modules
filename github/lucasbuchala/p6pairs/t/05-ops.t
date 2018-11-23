
use v6;
use Test;
use Duo;

ok Duo.new(1, 2)  eqv Duo.new(1, 2), 'eqv same key, same value';
ok Duo.new(1, 2) !eqv Duo.new(1, 0), 'not eqv same key, different value';
ok Duo.new(1, 2) !eqv Duo.new(0, 2), 'not eqv same value, different key';
ok Duo.new(1, 2) !eqv Duo.new(0, 0), 'not eqv different key, different value';

is-deeply Duo.new(1, 2) cmp Duo.new(1, 2), Same, '(1, 2) cmp (1, 2) == Same';
is-deeply Duo.new(1, 2) cmp Duo.new(1, 1), More, '(1, 2) cmp (1, 1) == More';
is-deeply Duo.new(1, 2) cmp Duo.new(1, 3), Less, '(1, 2) cmp (1, 3) == Less';
is-deeply Duo.new(1, 2) cmp Duo.new(0, 2), More, '(1, 2) cmp (0, 2) == More';
is-deeply Duo.new(1, 2) cmp Duo.new(2, 2), Less, '(1, 2) cmp (2, 2) == Less';

done-testing;

# vim: ft=perl6
