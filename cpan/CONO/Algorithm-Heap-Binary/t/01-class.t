use v6;

use Test;

use Algorithm::Heap::Binary;

my $heap = Algorithm::Heap::Binary.new;
isa-ok($heap, Algorithm::Heap::Binary);
does-ok($heap, Algorithm::Heap);
does-ok($heap, Iterable);

done-testing;

# vim: ft=perl6
