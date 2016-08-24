#!/usr/bin/env perl6

use v6.c;

use Test;

use Test::Deeply::Relaxed;

plan 28;

is-deeply-relaxed [], [];
is-deeply-relaxed [1, 2], [1, 2], 'non-empty array - same';
isnt-deeply-relaxed [], [1, 2], 'empty and non-empty array - different';
isnt-deeply-relaxed [1, 2], [], 'non-empty and empty array - different';

isnt-deeply-relaxed [1, 2], '1 2', 'array and string - different';
isnt-deeply-relaxed '1 2', [1, 2], 'string and array - different';
isnt-deeply-relaxed [1], 1, 'array and number - different';
isnt-deeply-relaxed 1, [1], 'array and number - different';

is-deeply-relaxed {}, {}, 'empty hash -same';
is-deeply-relaxed {:a(42), :password('mellon')}, {password => 'mellon', a => 42}, 'non-empty hash - same';
isnt-deeply-relaxed {}, {:password('mellon')}, 'empty and non-empty hash - different';
isnt-deeply-relaxed {:a(42)}, {}, 'non-empty and empty hash - different';

isnt-deeply-relaxed {}, [];
isnt-deeply-relaxed [], {}, 'empty array and empty hash - different';
isnt-deeply-relaxed {:a(42)}, ['a', 42], 'hash and array - different';
isnt-deeply-relaxed ['a', 42], {:a(42)}, 'array and hash - different';

is-deeply-relaxed {:a([1, 2, 3]), :more({:how('deep'), :does(['this', 'thing', 'go'])})},
    {:more({:does([<this thing go>]), how => 'deep'}), :a([1, 2, 3])},
    'a weird and wonderful hash';

is-deeply-relaxed (1, 2, 3).Seq, (1, 2, 3).Seq, 'seq - same';
is-deeply-relaxed (1, 2, 3).Seq, list(1, 2, 3), 'seq and list - same';
is-deeply-relaxed list(1, 2, 3), (1, 2, 3).Seq, 'list and seq - same';
isnt-deeply-relaxed (1, 2, 3).Seq, (1, 2, 3, 4).Seq, 'seq and diff seq - different';
isnt-deeply-relaxed (1, 2, 3).Seq, list(1, 2, 3, 4), 'seq and diff list - different';
isnt-deeply-relaxed list(1, 2, 3), (1, 2, 3, 4).Seq, 'list and diff seq - different';
isnt-deeply-relaxed (1, 2, 3...*), Seq(1, 2, 3, 4), 'infinite and finite seq - different';
isnt-deeply-relaxed (1, 2, 3...*), list(1, 2, 3, 4), 'infinite seq and finite list - different';
isnt-deeply-relaxed list(1, 2, 3, 4), (1, 2, 3...*), 'finite list and infinite seq - different';

isnt-deeply-relaxed (1, 2, 3).Seq, '1 2 3', 'seq and string - different';
isnt-deeply-relaxed '1 2 3', (1, 2, 3).Seq, 'string and seq - different';
