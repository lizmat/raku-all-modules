
use v6;
use Test;
use Duo;

my \p = Duo.new(10, 20);

ok p, 'return is true';

isa-ok p, Duo;

# .elems and aliases
is p.elems,   2, '.elems';
is p.Numeric, 2, '.Numeric';
is p.Int,     2, '.Int';

is +p, 2, 'operator +';

is p.key,   10, 'get key';
is p.value, 20, 'get value';

p.key   = 30;
p.value = 40;

is p.key,   30, 'set key';
is p.value, 40, 'set value';

p.set(50, 60);

is ~p, '50 => 60', '.set(k, v)';

is-deeply Duo(1, 2),             Duo.new(1, 2), 'can create with Duo(k, v)';
is-deeply Duo(key=>1, value=>2), Duo.new(1, 2), 'can create with Duo(:args)';
is-deeply Duo(1 => 2),           Duo.new(1, 2), 'can create with Duo(Pair)';
is-deeply Duo([1, 2]),           Duo.new(1, 2), 'can create with Duo([...])';

# p.clear;
# 
# ok !defined p.key,   'cleared .key';
# ok !defined p.value, 'cleared .value';

done-testing;

# vim: ft=perl6
