
use v6;
use Test;
use Duo;

my \o = Duo.new(1, 2);

## Coercions

is-deeply o.Duo,   o,          'instance to duo';
is-deeply o.Pair,  1=>2,       'instance to pair';
is-deeply o.Range, 1..2,       'instance to range';
is-deeply o.Array, [1,2],      'instance to array';
is-deeply o.List,  (1,2),      'instance to list';
is-deeply o.Slip,  (1,2).Slip, 'instance to slip';

## Type object

is-deeply Duo.Duo,   Duo,   'type to duo';
is-deeply Duo.Pair,  Pair,  'type to pair';
is-deeply Duo.Range, Range, 'type to range';
is-deeply Duo.Array, Array, 'type to array';
is-deeply Duo.List,  List,  'type to list';
is-deeply Duo.Slip,  Slip,  'type to slip';
is-deeply Duo.Hash,  Hash,  'type to hash';

## Allomorphs

is-deeply Duo.new(< 10   >).IntStr,     < 10   >, 'instance to IntStr';
is-deeply Duo.new(< 1e0  >).NumStr,     < 1e0  >, 'instance to NumStr';
is-deeply Duo.new(< 1/2  >).RatStr,     < 1/2  >, 'instance to RatStr';
is-deeply Duo.new(< 1+2i >).ComplexStr, < 1+2i >, 'instance to ComplexStr';

is-deeply Duo.IntStr,     IntStr,     'type to IntStr';
is-deeply Duo.NumStr,     NumStr,     'type to NumStr';
is-deeply Duo.RatStr,     RatStr,     'type to RatStr';
is-deeply Duo.ComplexStr, ComplexStr, 'type to ComplexStr';

done-testing;

# vim: ft=perl6
