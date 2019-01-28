use v6.c;

use Test::Declare;
use lib 't/lib';
use TDHelpers;

declare(
    ${
        name => 'no constructor args - stdout',
        call => {
            class => T::NoConstruct,
            method => 'blurt',
        },
        expected => {
            stdout => "NO NUM\n",
        },
    },
    ${
        name => 'with constructor args - stdout',
        call => {
            class => T::NoConstruct,
            construct => \(num => 1),
            method => 'blurt',
        },
        expected => {
            stdout => "GOT NUM: 1\n",
        },
    },
    ${
        name => 'stderr',
        call => {
            class => T::Math,
            construct => \( num => 3 ),
            method => 'stern',
        },
        expected => {
            stderr => "three\n",
        },
    },
    ${
        name => 'stdout',
        call => {
            class => T::Math,
            construct => \( num => 2 ),
            method => 'speak',
        },
        expected => {
            stdout => "two\n",
        },
    },
);
