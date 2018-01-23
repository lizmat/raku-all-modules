use v6.c;
use Test;
use P5times;

plan 10;

ok defined(::('&times')),       'is &times imported?';
ok !defined(P5times::{'&times'}), 'is &times externally NOT accessible?';

my ($user1,$system1,$cuser1,$csystem1) = times;
ok $user1   > 0, 'did we get some user CPU';
ok $system1 > 0, 'did we get some system CPU';
is $cuser1,   0, 'did we get no child user CPU';
is $csystem1, 0, 'did we get no child system CPU';

my ($user2,$system2,$cuser2,$csystem2) = times;
ok $user2   > $user1,   'did we get more user CPU';
ok $system2 > $system1, 'did we get more system CPU';
is $cuser2,   0,        'did we get no child user CPU';
is $csystem2, 0,        'did we get no child system CPU';

# vim: ft=perl6 expandtab sw=4
