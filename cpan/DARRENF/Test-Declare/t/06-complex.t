use v6.c;
use Test::Declare;
use lib 't/lib';
use TDHelpers;

declare(
    ${
        name => 'complex return values',
        call => {
            class => T::Complex,
            method => 'generate-complex',
        },
        args => \(4),
        expected => {
            return-value => T::Math.new(num=>4),
        },
    },
);
