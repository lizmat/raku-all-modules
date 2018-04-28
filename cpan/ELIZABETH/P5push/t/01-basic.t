use v6.c;
use Test;
use P5push;

plan 10;

ok defined(::('&push')),        'is &push imported?';
ok !defined(P5push::{'&push'}), 'is &push externally NOT accessible?';
ok defined(::('&pop')),         'is &pop imported?';
ok !defined(P5push::{'&pop'}),  'is &pop externally NOT accessible?';

my @a = 1;
is (push @a, 42), 2, 'does push return number of elems';
is @a, "1 42", 'did it actually push';

@*ARGS = <FOO BAR>;
is pop, "BAR", 'does bare pop pop from @*ARGS at top level';
is (pop @a),  42, 'does first specific pop also work';
is (pop @a),   1, 'does second specific pop also work';
is (pop @a), Nil, 'does third specific pop also work';

# vim: ft=perl6 expandtab sw=4
