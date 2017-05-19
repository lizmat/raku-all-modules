use v6;

use Test;
use Math::Primesieve;

plan 2;

ok my $iterator = Math::Primesieve::iterator.new, 'Make an iterator';

my $sum;
$sum += $iterator.next for ^1000000;

is $sum, 7472966967499, 'Sum lots of primes';
