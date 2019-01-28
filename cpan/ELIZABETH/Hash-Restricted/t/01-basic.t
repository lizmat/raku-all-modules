use v6.c;
use Test;

use Hash::Restricted;

plan 2 + 2 * 15;

is-deeply (my %h1 is restricted = a => 42, b => 666), %h1,
  'does STORE return self';
is-deeply (my %h2 is restricted<a b> = a => 42, b => 666), %h2,
  'does STORE return self';

for %h1, %h2 -> %h {
    ok %h.^name.ends-with('(restricted)'), 'is the name changed ok';

    ok %h<a>:exists, 'did the hash get initialized ok with a';
    is %h<a>,  42, 'did the hash get initialized ok with a';
    is %h<b>, 666, 'did the hash get initialized ok with b';
    is (%h<b> = 314), 314, 'could we assign to allowed key b';
    is %h<b>, 314, 'did the hash get assigned ok with b';

    is %h<a>:delete, 42, 'did the hash deleted ok with a';
    nok %h<a>:exists, 'did the hash remove a';
    is (%h<a> = 768), 768, 'can we re-create ok with a';

    %h = a => 43, b => 667;
    is %h<a>,  43, 'did the hash get re-initialized ok with a';
    is %h<b>, 667, 'did the hash get re-initialized ok with b';

    dies-ok { %h<c> }, 'not allowed to access c';
    dies-ok { %h<c> = 999 }, 'not allowed to assign to c';
    dies-ok { %h<c> := 999 }, 'not allowed to bind to c';
    dies-ok { %h = c => 999 }, 'not allowed to store c';
}

# vim: ft=perl6 expandtab sw=4
