use v6.c;
use Test::Declare;
use Test::Declare::Comparisons;
use Test::Declare::Suite;
use lib 't/lib';
use TDHelpers;

my class Numbers {
    method five { 5 }
    method twelve { 12 }
    method incr(Int $n is rw) { $n++ }
}

class MyTest does Test::Declare::Suite {
    method class { Numbers }
    my $n = 3;

    method tests {
        ${
            name => 'mutation',
            call => {
                method => 'incr',
            },
            args => \($n),
            expected => {
                # "$n will be greater than 3"
                mutates => roughly(&[>], 3),
            },
        },
        ${
            name => 'seq',
            call => {
                method => 'five',
            },
            expected => {
                return-value => roughly(&[~~], 1..10),
            },
        },
        ${
            name => 'negative seq',
            call => {
                method => 'twelve',
            },
            expected => {
                return-value => roughly(&[!~~], 1..10),
            },
        },
        ${
            name => 'subhashof',
            call => {
                class => Hash,
                construct => \({foo => 1, bar => 2}),
                method => 'clone',
            },
            expected => {
                return-value => roughly(&[subhashof], {foo => 1, bar => 2, quux => 3}),
            },
        },
        ${
            name => 'infix superhashof',
            call => {
                class => Hash,
                construct => \({foo => 1, bar => 2}),
                method => 'clone',
            },
            expected => {
                return-value => roughly(&[superhashof], {foo => 1}),
            },
        },
        ${
            name => 'Test::Deep style superhashof',
            call => {
                class => Hash,
                construct => \({foo => 1, bar => 2}),
                method => 'clone',
            },
            expected => {
                return-value => superhashof({foo => 1}),
            },
        },
    }
}

MyTest.new.run-me;
