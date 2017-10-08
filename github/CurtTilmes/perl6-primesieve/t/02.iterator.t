use v6;

use Test;
use Math::Primesieve;

plan 4;

ok my $iterator = Math::Primesieve::iterator.new, 'Make an iterator';

my @list;

@list.push($iterator.next) for ^10;

is @list, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29], 'Got 10 primes';

$iterator.skipto(1000);

@list = ();

@list.push($iterator.next) for ^10;

is @list, [1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061], 'Skip';

@list = ();

@list.push($iterator.prev) for ^10;

is @list, [1051, 1049, 1039, 1033, 1031, 1021, 1019, 1013, 1009, 997], 'Prev';

