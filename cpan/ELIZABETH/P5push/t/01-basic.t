use v6.c;
use Test;
use P5push;

plan 16;

ok defined(::('&push')),        'is &push imported?';
ok !defined(P5push::{'&push'}), 'is &push externally NOT accessible?';
ok defined(::('&pop')),         'is &pop imported?';
ok !defined(P5push::{'&pop'}),  'is &pop externally NOT accessible?';

my @a = 1;
is (push @a, 42), 2, 'does push return number of elems';
is @a, "1 42", 'did it actually push';
is (push @a, 666,667), 4, 'does push return number of elems';
is-deeply @a, [1,42,666,667], 'did it actually push';

is (pop @a), 667, 'does first specific pop also work';
is (pop @a), 666, 'does second specific pop also work';
is (pop @a),  42, 'does third specific pop also work';
is (pop @a),   1, 'does fourth specific pop also work';
is (pop @a), Nil, 'does fifth specific pop also work';

@*ARGS = <FOO BAR>;
is pop, "BAR", 'does bare pop pop from @*ARGS at top level (1)';
is pop, "FOO", 'does bare pop pop from @*ARGS at top level (2)';
is pop, Nil, 'does bare pop pop from @*ARGS at top level (3)';

# vim: ft=perl6 expandtab sw=4
