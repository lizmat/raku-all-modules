use v6.c;

use Test::Declare;
use lib 't/lib';
use TDHelpers;

declare(
    ${
        name => 'dies and throws',
        call => {
            class => T::Math,
            construct => \( num => 2 ),
            method => 'multiply',
        },
        args => \("eight"),
        expected => {
            dies => True,
            throws => 'Exception',
        },
    },
    ${
        name => 'lives',
        call => {
            class => T::Math,
            construct => \( num => 2 ),
            method => 'as-word',
        },
        expected => {
            lives => True,
        },
    },
);
