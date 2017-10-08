use v6;
use experimental :pack;
use Digest::MurmurHash3;

unit class Algorithm::BloomFilter;

has Rat $.error-rate;
has Int $.capacity;
has Int $.key-count;
has Int $.filter-length;
has Int $.num-hash-funcs;
has Int @.salts;
has Int @!filters;
has Int $!blankvec;

constant FILTER_BITS = 64;
constant UINT32_MAX  = 4294967295;

method BUILD(Rat:D :$!error-rate, Int:D :$!capacity) {
    my %filter-settings = self.calculate-shortest-filter-length(
        num-keys   => $!capacity,
        error-rate => $!error-rate,
    );
    $!key-count      = 0;
    $!filter-length  = %filter-settings<length>;
    $!num-hash-funcs = %filter-settings<num-hash-funcs>;
    @!salts          = self.create-salts(count => $!num-hash-funcs);

    # Create an empty filter
    0 .. ($!filter-length / FILTER_BITS).floor
        ==> map { @!filters[$_] = 0 };

    # Create a blank vector
    $!blankvec = 0;
}

method calculate-shortest-filter-length(Int:D :$num-keys, Rat:D :$error-rate --> Hash[Int]) {
    my Num $lowest-m;
    my Int $best-k = 1;

    for 1 ... 100 -> $k {
        my $m = (-1 * $k * $num-keys) / (log(1 - ($error-rate ** (1 / $k))));

        if (!$lowest-m.defined || ($m < $lowest-m)) {
            $lowest-m = $m;
            $best-k   = $k;
        }
    }

    my Int %result =
        length         => $lowest-m.Int + 1,
        num-hash-funcs => $best-k;
}

method create-salts(Int:D :$count --> Seq) {
    my Int %collisions;

    while %collisions.keys.elems < $count {
        my Int $c = UINT32_MAX.rand +& UINT32_MAX;
        %collisions{$c} = $c;
    }

    %collisions.values;
}

method get-cells(Cool:D $key, Int:D :$filter-length, Int:D :$blankvec, Int:D :@salts --> List) {
    my Int @cells;

    for @salts -> $salt {
        my Int $vec = $blankvec;
        my Int @pieces = murmurhash3_128(~$key, $salt);

        $vec = $vec +^ $_ for @pieces;

        @cells.push: $vec % $filter-length; # push bit-offset
    }

    |@cells;
}

method add(::?CLASS:D: Cool:D $key) {

    die "Exceeded filter capacity: {$!capacity}"
        if $!key-count >= $!capacity;

    $!key-count++;

    self.get-cells(
        $key,
        filter-length => $!filter-length,
        blankvec      => $!blankvec,
        salts         => @!salts,
    ) ==> map {
        my Int $i = ($_ / FILTER_BITS).floor;
        @!filters[$i] = @!filters[$i] +| 2 ** ($_ % FILTER_BITS);
    };
}

method check(::?CLASS:D: Cool:D $key --> Bool) {
    so (self.get-cells(
        $key,
        filter-length => $!filter-length,
        blankvec      => $!blankvec,
        salts         => @!salts,
    ) ==> map {
        my Int $i = ($_ / FILTER_BITS).floor;
        @!filters[$i] +& 2 ** ($_ % FILTER_BITS);
    }).all;
}


=begin pod

=head1 NAME

Algorithm::BloomFilter - A bloom filter implementation in Perl 6

=head1 SYNOPSIS

  use Algorithm::BloomFilter;

  my $filter = Algorithm::BloomFilter.new(
    capacity   => 100,
    error-rate => 0.01,
  );

  $filter.add("foo-bar");

  $filter.check("foo-bar"); # True

  $filter.check("bar-foo"); # False with possible false-positive

=head1 DESCRIPTION

Algorithm::BloomFilter is a pure Perl 6 implementation of L<Bloom Filter|https://en.wikipedia.org/wiki/Bloom_filter>, mostly based on L<Bloom::Filter|https://metacpan.org/pod/Bloom::Filter> from Perl 5.

Digest::MurmurHash3 is used for hashing from version 0.1.0.

=head1 METHODS

=head3 new(Rat:D :$error-rate, Int:D :$capacity)

Creates a Bloom::Filter instance.

=head3 add(Cool:D $key)

Adds a given key to filter instance.

=head3 check(Cool:D $key) returns Bool

Checks if a given key is in filter instance.

=head1 INTERNAL METHODS

=head3 calculate-shortest-filter-length(Int:D :$num-keys, Rat:D $error-rate) returns Hash[Int]

Calculates and returns filter's length and a number of hash functions.

=head3 create-salts(Int:D :$count) returns Seq[Int]

Creates and returns C<$count> unique and random uint32 salts.

=head3 get-cells(Cool:D $key, Int:D :$filter-length, Int:D :$blankvec, Int:D :@salts) returns List

Calculates and returns positions to check in a bit vector.

=head1 SEE ALSO

L<Bloom Filter|https://en.wikipedia.org/wiki/Bloom_filter>

L<Bloom::Filter|https://metacpan.org/pod/Bloom::Filter>

=head1 AUTHOR

yowcow <yowcow@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
