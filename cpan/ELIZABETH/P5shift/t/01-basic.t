use v6.c;
use Test;
use P5shift;

plan 16;

ok defined(::('&shift')),           'is &shift imported?';
ok !defined(P5shift::{'&shift'}),   'is &shift externally NOT accessible?';
ok defined(::('&unshift')),         'is &unshift imported?';
ok !defined(P5shift::{'&unshift'}), 'is &unshift externally NOT accessible?';

my @a = 1;
is (unshift @a, 42), 2, 'does unshift return number of elems';
is @a, "42 1", 'did it actually unshift';
is (unshift @a, 666,667), 4, 'does unshift return number of elems';
is-deeply @a, [666,667,42,1], 'did it actually unshift';

is (shift @a), 666, 'does first specific shift also work';
is (shift @a), 667, 'does second specific shift also work';
is (shift @a),  42, 'does third specific shift also work';
is (shift @a),   1, 'does fourth specific shift also work';
is (shift @a), Nil, 'does fifth specific shift also work';

@*ARGS = <FOO BAR>;
is shift, "FOO", 'does bare shift shift from @*ARGS at top level (1)';
is shift, "BAR", 'does bare shift shift from @*ARGS at top level (2)';
is shift, Nil, 'does bare shift shift from @*ARGS at top level (3)';

# vim: ft=perl6 expandtab sw=4
