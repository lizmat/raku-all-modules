#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Scheme::Gambit;

my $gambit = Inline::Scheme::Gambit.new();

is $gambit.run('#t'), True;
is $gambit.run('#f'), False;
cmp-ok $gambit.run('0'), '==', 0;
cmp-ok $gambit.run('5'), '==', 5;
cmp-ok $gambit.run('1/3'), '==', 1/3;
cmp-ok $gambit.run('1.0'), '==', 1.0;
cmp-ok $gambit.run('5.5'), '==', 5.5;
cmp-ok $gambit.run('1+2i'), '==', 1+2i;
is $gambit.run('"gambit-c"'), 'gambit-c';
is $gambit.run(q{(cons "foo" "bar")}), ("foo" => "bar");
is-deeply $gambit.run(q{'#(#t 5 5.5 "gambit-c")}), [True, 5, 5.5e0, "gambit-c"];
is-deeply $gambit.run(q{'(1 2 (3 "hello") "world")}), [1, 2, [3, "hello"], "world"];
is-deeply $gambit.run(q{'(#t 5 5.5 "gambit-c")}), [True, 5, 5.5e0, "gambit-c"];
is-deeply $gambit.run(q{
        (let ((t (make-table)))
            (table-set! t 1 "foo")
            (table-set! t "bar" "baz")
            t)
    }), { 1 => "foo", "bar" => "baz" };

done-testing;
