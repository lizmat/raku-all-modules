use v6;
use Algorithm::BloomFilter;

my $filter = Algorithm::BloomFilter.new(
    error-rate => 0.01,
    capacity => 10_000,
);

say "Adding items to filter";

$filter.add($_) for 1 .. 100;

say "Checking items in filter";

say $filter.check($_) for 1 .. 100;
