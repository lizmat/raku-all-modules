use v6.c;
use Test;

use Sub::Memoized;

plan 2 * 3 * 12;

my $executed = 0;
my $ft = 42;
role Foo { } # to check if mixins don't break things

for
    sub ($a) is memoized                   { ++$executed; $a + $a },
    'is memoized',
    sub ($a) is memoized( my %h )          { ++$executed; $a + $a },
    'is memoized(my %h)',
    sub ($a) is memoized( my %h does Foo ) { ++$executed; $a + $a },
    'is memoized(my %h does Foo)'
-> &code, $what {
    $executed = 0;

    is code(42), 84, "$what: positional, did we get right result";
    is $executed, 1, "$what: positional, did we execute the body once";

    is code(42), 84, "$what: positional, did we get right result";
    is $executed, 1, "$what: positional, did we not execute the body this time";

    is code($ft), 84, "$what: positional, did we get right result";
    is $executed, 1, "$what: positional, did we not execute the body this time";

    is code(666), 1332, "$what: positional, did we get right result";
    is $executed, 2, "$what: positional, did we execute the body again";

    is code(42), 84, "$what: positional, did we get right result";
    is $executed, 2, "$what: positional, did we not execute the body this time";

    is code(666), 1332, "$what: positional, did we get right result";
    is $executed, 2, "$what: positional, did we not execute the body this time";
}

for
    sub (:$a) is memoized                   { ++$executed; $a + $a + 1 },
    'is memoized',
    sub (:$a) is memoized( my %h )          { ++$executed; $a + $a + 1 },
    'is memoized(my %h)',
    sub (:$a) is memoized( my %h does Foo ) { ++$executed; $a + $a + 1 },
    'is memoized(my %h does Foo)'
-> &code, $what {
    $executed = 0;

    is code(a => 42), 85, "$what: named, did we get right result";
    is $executed, 1, "$what: named, did we execute the body once";

    is code(a => 42), 85, "$what: named, did we get right result";
    is $executed, 1, "$what: named, did we not execute the body this time";

    is code(a => $ft), 85, "$what: positional, did we get right result";
    is $executed, 1, "$what: positional, did we not execute the body this time";

    is code(a => 666), 1333, "$what: named, did we get right result";
    is $executed, 2, "$what: named, did we execute the body again";

    is code(a => 42), 85, "$what: named, did we get right result";
    is $executed, 2, "$what: named, did we not execute the body this time";

    is code(a => 666), 1333, "$what: named, did we get right result";
    is $executed, 2, "$what: named, did we not execute the body this time";
}

# vim: ft=perl6 expandtab sw=4
