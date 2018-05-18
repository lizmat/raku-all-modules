use v6.c;

use Test::Declare;
use lib 't/lib';
use TDHelpers;

declare(
    ${
        name => 'positional args',
        call => {
            class => T::Math,
            construct => \( num => 2 ),
            method => 'multiply',
        },
        args => \(8),
        expected => {
            return-value => 16,
        },
    },
    ${
        name => 'no args',
        call => {
            class => T::Math,
            construct => \( num => 2 ),
            method => 'as-word',
        },
        expected => {
            return-value => 'two',
        },
    },
    ${
        name => 'named args',
        call => {
            class => T::Math,
            construct => \( num => 2 ),
            method => 'add',
        },
        args => \(adder => 4.5),
        expected => {
            return-value => 6.5,
        },
    },
);
