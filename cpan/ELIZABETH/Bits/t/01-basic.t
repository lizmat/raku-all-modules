use v6.c;
use Test;
use Bits;

my @tests = (
  0,  0,  (),      False,
  1,  1,  (0,),    False,
  2,  1,  (1,),    True,
  3,  2,  (0,1),   True,
  4,  1,  (2,),    False,
  5,  2,  (0,2),   False,
  6,  2,  (1,2),   True,
  7,  3,  (0,1,2), True,
  8,  1,  (3,),    False,
  9,  2,  (0,3),   False,
);

plan (@tests / 4) * 3;

for @tests -> $value, $bitcnt, $bits, $bit1 {
    is bit($value,1),  $bit1,   "is bit($value,1) $bit1?";
    is bitcnt($value), $bitcnt, "is bitcnt($value) == $bitcnt?";
    is bits($value),   $bits,   "is bits($value) == $bits?"
}

# vim: ft=perl6 expandtab sw=4
