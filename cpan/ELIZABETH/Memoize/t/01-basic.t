use v6.c;
use Test;

plan 9;

{
    use Memoize;
    ok defined(::('&memoize')),           '&memoize imported?';
    ok defined(Memoize::{'&memoize'}),    '&memoize externally accessible?';
    ok !defined(::('&unmemoize')),        '&unmemoize *not* imported?';
    ok defined(Memoize::{'&unmemoize'}),  '&unmemoize externally accessible?';
    ok !defined(::('&flush_cache')),      '&flush_cache *not* imported?';
    ok defined(Memoize::{'&flush_cache'}),'&flush_cache externally accessible?';
}

{
    use Memoize <memoize unmemoize flush_cache>;
    ok defined(::('&memoize')),     '&memoize imported?';
    ok defined(::('&unmemoize')),   '&unmemoize *not* imported?';
    ok defined(::('&flush_cache')), '&flush_cache *not* imported?';
}

# vim: ft=perl6 expandtab sw=4
