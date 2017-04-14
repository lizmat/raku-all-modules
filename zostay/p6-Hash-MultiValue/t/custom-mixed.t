#!/usr/bin/env perl6

use v6;

use Test;
use Hash::MultiValue;

my %mixed-hash = a => [1, 2], b => (3, 4), c => 5;

sub iterator($k, @v) { |@v.reverse.map({ $k => $_ }) }

my @tests = (
    from-mixed-hash => { Hash::MultiValue.new(:%mixed-hash, :iterate(Array), :&iterator) },
    new-mixed-hash  => { Hash::MultiValue.new(:%mixed-hash, :iterate(Array), :&iterator) },
);

for @tests -> $test {
    my ($name, &construct) = $test.kv;

    subtest {
        my %t := construct();

        is-deeply %t('a'), (2, 1), 'a = 2, 1';
        is-deeply %t('b'), ($(3, 4),), 'b = [ 3, 4 ]';
        is-deeply %t('c'), (5,), 'c = 5';
    }, $name;
}

done-testing;
