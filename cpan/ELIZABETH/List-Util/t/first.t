use v6.c;

use List::Util <first>;
use Test;

plan 10;
my $v is default(Nil);

ok defined(&first), 'first defined';

$v = first { 8 == ($_ - 1) }, 9,4,5,6;
is $v, 9, 'one more than 8';

$v = first { 0 }, 1,2,3,4;
is $v, Nil, 'none match';

$v = first( { 0 } );
is $v, Nil, 'no args';

$v = first { $_[1] le "e" and "e" le $_[2] }, $(<a b c>), $(<d e f>), $(<g h i>);
is-deeply $v, $(<d e f>), 'reference args';

# Check that try{} inside the block works correctly
my $i = 0;
$v = first { try { die }; ($i == 5, $i = $_)[0] }, 0,1,2,3,4,5,5;
is $v, 5, 'use of try';

$v = try { first { die if $_ }, 0,0,1 };
is $v, Nil, 'use of die';

# Can we leave the sub with 'return'?
$v = first sub ($_) { return $_ > 6 }, 2,4,6,12;
is $v, 12, 'return';

# ... even in a loop?
$v = first sub ($_) { while 1 { return $_ > 6 } }, 2,4,6,12;
is $v, 12, 'return from loop';

# Does it work from another package?
package Foo {
    is List::Util::first({$_>4},1..4,24), 24, 'other package';
}

# vim: ft=perl6 expandtab sw=4
