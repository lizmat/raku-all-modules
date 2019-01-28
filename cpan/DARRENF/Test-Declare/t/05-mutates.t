use v6.c;
use Test::Declare;
use lib 't/lib';
use TDHelpers;

declare(
    ${
        name => 'mutation',
        call => {
            class => T::Mutation,
            method => 'increment-all',
        },
        args => \( [1,2,3] ),
        expected => {
            mutates => [2,3,4],
        },
    },
);
