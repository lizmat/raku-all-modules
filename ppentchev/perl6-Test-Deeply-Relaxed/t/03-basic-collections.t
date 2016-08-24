#!/usr/bin/env perl6

use v6.c;

use Test;

use Test::Deeply::Relaxed;

plan 22;

is-deeply-relaxed set(1, 2, 'a'), set('a', 2, 1), 'set - same';
isnt-deeply-relaxed set(1, 2, 'a'), set('a', 1), 'set - different';

isnt-deeply-relaxed set('a', 'b'), {:a, :b}, 'set and hash - different';
isnt-deeply-relaxed {:a, :b}, set('a', 'b'), 'hash and set - different';

is-deeply-relaxed bag(1, 2, 'a'), bag('a', 2, 1), 'bag - same';
is-deeply-relaxed bag(1, 2, 'a', 1), bag('a', 1, 2, 1), 'bag - different';
isnt-deeply-relaxed bag(1, 2, 'a'), bag('a', 1, 2, 1), 'bag - different';

isnt-deeply-relaxed bag(1, 2, 'a'), set('a', 2, 1), 'bag and set - different';
isnt-deeply-relaxed set('a', 2, 1), bag(1, 2, 'a'), 'set and bag - different';
isnt-deeply-relaxed bag('a', 'b', 'a'), { :a(2), :b(1) }, 'bag and hash - different';
isnt-deeply-relaxed { :a(2), :b(1) }, bag('a', 'b', 'a'), 'hash and bag - different';

# Let's pretend that a mix is a bag, okay?

is-deeply-relaxed mix(1, 2, 'a'), mix('a', 2, 1), 'mix - same';
is-deeply-relaxed mix(1, 2, 'a', 1), mix('a', 1, 2, 1), 'mix - different';
isnt-deeply-relaxed mix(1, 2, 'a'), mix('a', 1, 2, 1), 'mix - different';

isnt-deeply-relaxed mix(1, 2, 'a'), set('a', 2, 1), 'mix and set - different';
isnt-deeply-relaxed set('a', 2, 1), mix(1, 2, 'a'), 'set and mix - different';
isnt-deeply-relaxed mix('a', 'b', 'a'), { :a(2), :b(1) }, 'mix and hash - different';
isnt-deeply-relaxed { :a(2), :b(1) }, mix('a', 'b', 'a'), 'hash and mix - different';

is-deeply-relaxed { :a(1), :b(2) }.Mix, bag('b', 'a', 'b'), 'mix and bag - same';
is-deeply-relaxed bag('b', 'a', 'b'), { :a(1), :b(2) }.Mix, 'bag and mix - same';
isnt-deeply-relaxed { :a(1.1), :b(2) }.Mix, bag('b', 'a', 'b'), 'mix and bag - different';
isnt-deeply-relaxed bag('b', 'a', 'b'), { :a(1.1), :b(2) }.Mix, 'bag and mix - different';
