#!perl6

use lib 'lib';
use Test;
use Test::Output;

my &test-code = sub {
    say 42;
    note 'warning!';
    say "After warning";
};

output-is   &test-code, "42\nwarning!\nAfter warning\n", 'testing output-is';
output-like &test-code, /42.+warning.+After/, 'testing output-like';
stdout-is   &test-code, "42\nAfter warning\n";
stdout-like &test-code, /42/;
stderr-is   &test-code, "warning!\n";
stderr-like &test-code, /^ "warning!\n" $/;

is output-from( &test-code ), "42\nwarning!\nAfter warning\n",
    'output-from works';
is stdout-from( &test-code ), "42\nAfter warning\n", 'stdout-from works';
is stderr-from( &test-code ), "warning!\n", 'stderr-from works';

done-testing;
