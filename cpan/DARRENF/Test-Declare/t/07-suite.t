use v6.c;
use Test::Declare::Suite;
use lib 't/lib';
use TDHelpers;

class MyTest does Test::Declare::Suite {
    method class { T::Math }
    method method { 'multiply' }
    method construct { \( num => 3 ) }

    method tests {
        ${
            name => 'multiply',
            args => \(4),
            expected => {
                return-value => 12,
            },
        },
        ${
            name => 'override method',
            call => {
                method => 'as-word',
            },
            expected => {
                return-value => 'three',
            },
        },
        ${
            name => 'override construct',
            call => {
                construct => \(num => 4),
            },
            args => \(4),
            expected => {
                return-value => 16,
            },
        },
        ${
            name => 'override everything',
            call => {
                class => T::Complex,
                method => 'generate-complex',
                construct => \(),
            },
            args => \(4),
            expected => {
                return-value => T::Math.new(num=>4),
            },
        };
    }
}

MyTest.new().run-me();
