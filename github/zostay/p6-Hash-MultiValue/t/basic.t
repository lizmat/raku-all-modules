#!/usr/bin/env perl6

use v6;

use Test;
use Hash::MultiValue;

my @kv = 'a', 1, 'b', 2, 'c', 3, 'a', 4;
my @pairs = a => 1, b => 2, c => 3, a => 4;
my %hash = a => [1, 4], b => 2, c => 3;

my @tests = (
    from-kv-array     => { Hash::MultiValue.from-kv(@kv) },
    from-pairs-array  => { Hash::MultiValue.from-pairs(@pairs) },
    from-mixed-hash   => { Hash::MultiValue.from-mixed-hash(%hash) },
    from-kv-slurpy    => { Hash::MultiValue.from-kv(|@kv) },
    from-pairs-slurpy => { Hash::MultiValue.from-pairs(|@pairs) },
    from-mixed-slurpy => { Hash::MultiValue.from-mixed-hash(|%hash) },
    new-kv-array      => { Hash::MultiValue.new(:@kv) },
    new-pairs-array   => { Hash::MultiValue.new(:@pairs) },
    new-mixed-hash    => { Hash::MultiValue.new(:mixed-hash(%hash)) },
);

for @tests -> $test {
    my ($name, &construct) = $test.kv;

    subtest {
        my %t := construct();

        my $a = 10;
        %t<a> := $a;
        is %t<a>, 10, 'correct value after bind';
        $a = 42;
        is %t<a>, 42, 'correct value after change elsewhere';

        my $b1 = 11;
        my $b2 = 12;
        %t<b> :delete;
        %t.push('b' => $b1, 'b' => $b2);
        is %t('b'), (11, 12), 'b = 11, 12';
        $b1 = 13;
        is %t('b'), (13, 12), 'b = 13, 12';
        $b2 = 14;
        is %t('b'), (13, 14), 'b = 13, 14';
    }

    subtest {
        my %t := construct();

        is %t<a>, 4, 'a = 4';
        is %t<b>, 2, 'b = 2';
        is %t<c>, 3, 'c = 3';

        is-deeply %t('a'), (1, 4).list, 'a = 1, 4';
        is-deeply %t('b'), (2).list, 'b = 2';
        is-deeply %t('c'), (3).list, 'c = 3';
        is %t.elems, 3, '.elems';
        is %t.all-elems, 4, '.all-elems';

        %t<b> = 5;
        %t<d> = 6;

        is %t<a>, 4, 'a = 4';
        is %t<b>, 5, 'b = 5';
        is %t<c>, 3, 'c = 3';
        is %t<d>, 6, 'd = 6';

        is-deeply %t('a'), (1, 4).list, 'a = 1, 4';
        is-deeply %t('b'), (5).list, 'b = 5';
        is-deeply %t('c'), (3).list, 'c = 3';
        is-deeply %t('d'), (6).list, 'd = 6';

        %t<a> = 7;

        is %t<a>, 7, 'a = 7';
        is %t<b>, 5, 'b = 5';
        is %t<c>, 3, 'c = 3';
        is %t<d>, 6, 'd = 6';

        is-deeply %t('a'), (7).list, 'a = 7';
        is-deeply %t('b'), (5).list, 'b = 5';
        is-deeply %t('c'), (3).list, 'c = 3';
        is-deeply %t('d'), (6).list, 'd = 6';

        %t('b') = 8, 9;
        %t('c') = 10;
        %t('e') = 11, 12;
        %t('f') = 13;

        is %t<a>, 7, 'a = 7';
        is %t<b>, 9, 'b = 9';
        is %t<c>, 10, 'c = 10';
        is %t<d>, 6, 'd = 6';
        is %t<e>, 12, 'e = 12';
        is %t<f>, 13, 'f = 13';

        is-deeply %t('a'), (7).list, 'a = 7';
        is-deeply %t('b'), (8, 9).list, 'b = 8, 9';
        is-deeply %t('c'), (10).list, 'c = 10';
        is-deeply %t('d'), (6).list, 'd = 6';
        is-deeply %t('e'), (11, 12).list, 'e = 11, 12';
        is-deeply %t('f'), (13).list, 'f = 13';
        is %t.elems, 6, '.elems';
        is %t.all-elems, 8, '.all-elems';

        subtest {
            my @expected = (a => 7, b => 9, c => 10, d => 6, e => 12, f => 13);
            subtest {
                my %expected = @expected;
                for %t.kv -> $k, $v {
                    my $exp-v = %expected{$k} :delete;
                    is $v, $exp-v, "expected value found for key $k";
                }

                is %expected.elems, 0, 'no extra values left';
            }, '.kv';

            subtest {
                my %expected = @expected;
                for %t.pairs -> $p {
                    my $exp-v = %expected{$p.key} :delete;
                    is $p.value, $exp-v, "expected value found for {$p.key}";
                }

                is %expected.elems, 0, 'no extra values left';
            }, '.pairs';

            subtest {
                my %expected = @expected;
                for %t.antipairs -> $p {
                    my $exp-v = %expected{$p.value} :delete;
                    is $p.key, $exp-v, "expected value found for {$p.key}";
                }

                is %expected.elems, 0, 'no extra values left';
            }, '.antipairs';

            subtest {
                my %expected = @expected;
                for %t.invert -> $p {
                    my $exp-v = %expected{$p.value} :delete;
                    is $p.key, $exp-v, "expected value found for {$p.key}";
                }

                is %expected.elems, 0, 'no extra values left';
            }, '.invert';

            subtest {
                my %expected = @expected;

                for flat %t.keys Z %t.values -> $k, $v {
                    my $exp-v = %expected{$k} :delete;
                    is $v, $exp-v, "expected value matched to $k";
                }

                is %expected.elems, 0, 'no extra keys left';
            }, '.keys and .values';
        }, 'single list methods';

        subtest {
            # We don't care what order the keys are in, but the order of the
            # values within the keys relative to one another is very important.

            my sub expected {
                my %expected = (
                    a => [a => 7],
                    b => [b => 8, b => 9],
                    c => [c => 10],
                    d => [d => 6],
                    e => [e => 11, e => 12],
                    f => [f => 13],
                );
                for %expected.kv -> $k, $v {
                    %expected{$k} = [];
                    for @($v) -> $e  {
                        %expected{$k}.append: $e
                    }
                }
                %expected;
            }

            subtest {
                my %expected = expected();

                for %t.all-kv -> $k, $v {
                    my $exp-p = %expected{$k}.shift;
                    is $v, $exp-p.value, "expected value matched to $k";
                }

                is %expected.values.grep(*.elems > 0).elems, 0, 'no extra pairs left';
            }, '.all-kv';

            subtest {
                my %expected = expected();

                for %t.all-pairs -> $p {
                    my $exp-p = %expected{$p.key}.shift;
                    is $p.value, $exp-p.value, "expected value matched to {$p.key}";
                }

                is %expected.values.grep(*.elems > 0).elems, 0, 'no extra pairs left';
            }, '.all-pairs';

            subtest {
                my %expected = expected();

                # diag %t.all-antipairs.perl;
                for %t.all-antipairs -> $p {
                    my $exp-p = %expected{$p.value}.shift;
                    is $p.value, $exp-p.key, "expected value matched to {$p.key}";
                }

                is %expected.values.grep(*.elems > 0).elems, 0, 'no extra pairs left';
            }, '.all-antipairs';

            subtest {
                my %expected = expected();

                # diag %t.all-invert.perl;
                for %t.all-invert -> $p {
                    my $exp-p = %expected{$p.value}.shift;
                    is $p.value, $exp-p.key, "expected value matched to {$p.key}";
                }

                is %expected.values.grep(*.elems > 0).elems, 0, 'no extra pairs left';
            }, '.all-invert';

            subtest {
                my %expected = expected();

                for flat %t.all-keys Z %t.all-values -> $k, $v {
                    my $exp-p = %expected{$k}.shift;
                    is $v, $exp-p.value, "expected key and value matched to $k";
                }
            }, '.all-keys and .all-values';
        }, 'all-pairs list methods';

        is %t.perl, 'Hash::MultiValue.from-pairs(:a(7), :b(8), :b(9), :c(10), :d(6), :e(11), :e(12), :f(13))', ".perl";
        is %t.gist, 'Hash::MultiValue.from-pairs(a => 7, b => 8, b => 9, c => 10, d => 6, e => 11, e => 12, f => 13)', ".gist";

        %t.push: a => 14, 'c', 15, 'e' => 16;

        is %t<a>, 14, 'a = 14';
        is %t<b>, 9, 'b = 9';
        is %t<c>, 15, 'c = 15';
        is %t<d>, 6, 'd = 6';
        is %t<e>, 16, 'e = 16';
        is %t<f>, 13, 'f = 13';

        is-deeply %t('a'), (7, 14).list, 'a = 7, 14';
        is-deeply %t('b'), (8, 9).list, 'b = 8, 9';
        is-deeply %t('c'), (10, 15).list, 'c = 10, 15';
        is-deeply %t('d'), (6).list, 'd = 6';
        is-deeply %t('e'), (11, 12, 16).list, 'e = 11, 12, 16';
        is-deeply %t('f'), (13).list, 'f = 13';
    }, $name;
}

done-testing;
