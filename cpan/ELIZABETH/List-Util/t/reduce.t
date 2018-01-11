use v6.c;

use List::Util <reduce min>;

use Test;
plan 16;

ok defined(&reduce), 'reduce defined';

my $v is default(Nil) = reduce( { ... } );

is $v, Nil, 'no args';

$v = reduce -> $a, $b { $a / $b }, 756,3,7,4;
is $v, 9, '4-arg divide';

$v = reduce -> $a, $b { $a / $b }, 6;
is $v, 6, 'one arg';

my @a = rand xx 20;
$v = reduce -> $a, $b { $a < $b ?? $a !! $b }, @a;
is $v, min(@a), 'min';

@a = ("a" .. "z").pick(20);
$v = reduce -> $a, $b { $a ~ $b }, @a;
is $v, @a.join, 'concat';

sub add($a,$b) { $a + $b }
$v = reduce -> $a, $b { add($a,$b) }, 3, 2, 1;
is $v, 6, 'call sub within';
$v = reduce &add, 1,2,3;
is( $v, 6, 'sub reference');

# Check that try {} inside the block works correctly
$v = reduce -> $a, $b { try { die }; $a + $b }, 0,1,2,3,4;
is $v, 10, 'use try {}';

$v = !defined try { reduce -> $a, $b { die if $b > 2; $a + $b }, 0,1,2,3,4 };
ok $v, 'die';

$v = reduce -> $a, $b { use MONKEY; EVAL "$a + $b" }, 1,2,3;
is $v, 6, 'EVAL string';

my $a = 8;
my $b = 9;
$v = reduce -> $a, $b { $a * $b }, 1,2,3;
is $a, 8, '$a not touched';
is $b, 9, '$b not touched';

# Can we leave the sub with 'return'?
$v = reduce sub ($a,$b) { return $a+$b }, 2,4,6;
is $v, 12, 'return';

# ... even in a loop?
$v = reduce sub ($a,$b) { loop { return $a+$b } }, 2,4,6;
is $v, 12, 'return from loop';

# Does it work from another package?
package Foo {
    is List::Util::reduce( -> $a, $b { $a*$b }, 1..4 ), 24, 'other package';
}

# vim: ft=perl6 expandtab sw=4
