use v6.c;
use Test;

use Array::Agnostic;

class MyArray does Array::Agnostic {
    has @!array;

    method AT-POS($pos)          is raw { @!array.AT-POS($pos)         }
    method BIND-POS($pos,\value) is raw { @!array.BIND-POS($pos,value) }
    method EXISTS-POS($pos)             { @!array.EXISTS-POS($pos)     }
    method DELETE-POS($pos)             { @!array.DELETE-POS($pos)     }
    method elems()                      { @!array.elems                }
}

plan 20;

my @a is MyArray = 1 .. 10;
is @a.elems, 10, 'did we get 10 elements';
is @a.end,    9, 'is index 9 the last element';
is-deeply @a.shape, (*,), 'is the shape ok';

is @a.gist,            "[1 2 3 4 5 6 7 8 9 10]", 'does .gist work ok';
is @a.Str,              "1 2 3 4 5 6 7 8 9 10",  'does .Str work ok';
is @a.perl, "MyArray.new(1,2,3,4,5,6,7,8,9,10)", 'does .perl work ok';

subtest {
    plan 10;
    my int $value = 0;
    is $_, ++$value, "did iteration {$value -1} produce $value"
      for @a;
}, 'checking iterator';

subtest {
    plan 10;
    is @a[$_], $_ + 1, "did element $_ produce {$_ + 1}"
      for ^10;
}, 'checking [x]';

subtest {
    plan 10;
    is @a[* - $_], 11 - $_, "did element * - $_ produce {11 - $_}"
      for 1 .. 10;
}, 'checking [* - x]';

subtest {
    plan 5;
    ok @a[9]:exists, 'does last element exist';
    is @a[9]:delete, 10, 'does :delete work on last element';
    nok @a[9]:exists, 'does last element no longer exist';
    is @a.elems, 9, 'do we have one element less now: elems';
    is @a.end,   8, 'do we have one element less now: end';
}, 'deletion of last element';

subtest {
    plan 5;
    is-deeply @a[3,5,7]:exists, (True,True,True),
      'can we check existence of an existing slice';
    is-deeply @a[3,5,7]:delete, (4,6,8),
      'can we remove an existing slice';
    is-deeply @a[3,5,7]:exists, (False,False,False),
      'can we check existence of an non-existing slice';
    is @a.elems, 9, 'did we keep same number of elements';
    is @a.end,   8, 'did we keep same last element';
}, 'can we delete a slice';

subtest {
    plan 3;
    is-deeply @a[^5]:v, (1,2,3,5), 'does a value slice work';
    is-deeply @a[]:v, (1,2,3,5,7,9), 'does a value zen-slice work';
    is-deeply @a[*]:v, (1,2,3,5,7,9), 'does a value whatever-slice work';
}, 'can we do value slices';

subtest {
    plan 11;
    is-deeply @a.keys, (0,1,2,3,4,5,6,7,8),
      'does .keys work';
    is-deeply @a.values, (1,2,3,Any,5,Any,7,Any,9),
      'does .values work';
    is-deeply @a.pairs, (0=>1,1=>2,2=>3,3=>Any,4=>5,5=>Any,6=>7,7=>Any,8=>9),
      'does .pairs work';
    is-deeply @a.kv, (0,1,1,2,2,3,3,Any,4,5,5,Any,6,7,7,Any,8,9),
      'does .kv work';

    is-deeply @a.head, 1, 'does .head work';
    is-deeply @a.head(3), (1,2,3), 'does .head(3) work';
    is-deeply @a.tail, 9, 'does .tail work';
    is-deeply @a.tail(3), (7,Any,9), 'does .tail(3) work';

    is-deeply @a.list, List.new(1,2,3,Any,5,Any,7,Any,9),
      'does .list work';
    is-deeply @a.List, List.new(1,2,3,Any,5,Any,7,Any,9),
      'does .List work';
    is-deeply @a.Array, Array.new(1,2,3,Any,5,Any,7,Any,9),
      'does .Array work';
}, 'check iterator based methods';

subtest {
    plan 14;
    is-deeply @a.push(42), @a, 'did .push return self';
    is @a.elems, 10, 'did we increase number of elements';
    is @a.end,    9, 'did we increase the last index';
    is @a[9], 42, 'did we get the right value after .push';

    is-deeply @a.append(666), @a, 'did .append return self';
    is @a.elems, 11, 'did we increase number of elements';
    is @a.end,   10, 'did we increase the last index';
    is @a[10],  666, 'did we get the right value after .append';

    is @a.pop,  666, 'did .pop return right value I';
    is @a.pop,   42, 'did .pop return right value II';
    is @a.elems,  9, 'did we decrease number of elements';
    is @a.end,    8, 'did we decrease the last index';
    is @a[ 9],  Any, 'did the elements value disappear I';
    is @a[10],  Any, 'did the elements value disappear II';
}, 'test .push / .append / .pop one element';

subtest {
    plan 11;
    is-deeply @a.push([42,666]), @a, 'did .push return self';
    is @a.elems, 10, 'did we increase number of elements';
    is @a.end,    9, 'did we increase the last index';
    is-deeply @a[9], [42,666], 'did we get the right value after .push';

    is-deeply @a.append([999,1000]), @a, 'did .append return self';
    is @a.elems, 12, 'did we increase number of elements';
    is @a.end,   11, 'did we increase the last index';
    is @a[10],  999, 'did we get the right value after .append I';
    is @a[11], 1000, 'did we get the right value after .append II';

    @a.pop for ^3;
    is @a.elems,  9, 'did we decrease number of elements';
    is @a.end,    8, 'did we decrease the last index';
}, 'test .push / .append / .pop one flattenable element';

subtest {
    plan 12;
    is-deeply @a.push(42,666), @a, 'did .push return self';
    is @a.elems, 11, 'did we increase number of elements';
    is @a.end,   10, 'did we increase the last index';
    is @a[ 9],   42, 'did we get the right value after .push I';
    is @a[10],  666, 'did we get the right value after .push II';

    is-deeply @a.append(999,1000), @a, 'did .append return self';
    is @a.elems, 13, 'did we increase number of elements';
    is @a.end,   12, 'did we increase the last index';
    is @a[11],  999, 'did we get the right value after .append I';
    is @a[12], 1000, 'did we get the right value after .append II';

    @a.pop for ^4;
    is @a.elems,  9, 'did we decrease number of elements';
    is @a.end,    8, 'did we decrease the last index';
}, 'test .push / .append / .pop multiple elements';

subtest {
    plan 16;
    is-deeply @a.unshift(42), @a, 'did .unshift return self';
    is @a.elems, 10, 'did we increase number of elements';
    is @a.end,    9, 'did we increase the last index';
    is @a[0], 42, 'did we get the right value after .unshift';

    is-deeply @a.prepend(666), @a, 'did .prepend return self';
    is @a.elems, 11, 'did we increase number of elements';
    is @a.end,   10, 'did we increase the last index';
    is @a[0],   666, 'did we get the right value after .prepend';

    is @a.shift, 666, 'did .shift return right value I';
    is @a.elems,  10, 'did we decrease number of elements';
    is @a.end,     9, 'did we decrease the last index';
    is @a.shift,  42, 'did .shift return right value II';
    is @a.elems,   9, 'did we decrease number of elements';
    is @a.end,     8, 'did we decrease the last index';
    is @a[ 9],   Any, 'did the elements value disappear I';
    is @a[10],   Any, 'did the elements value disappear II';
}, 'test .unshift / .prepend / .shift one element';

subtest {
    plan 11;
    is-deeply @a.unshift([42,666]), @a, 'did .unshift return self';
    is @a.elems, 10, 'did we increase number of elements';
    is @a.end,    9, 'did we increase the last index';
    is-deeply @a[0], [42,666], 'did we get the right value after .unshift';

    is-deeply @a.prepend([999,1000]), @a, 'did .prepend return self';
    is @a.elems, 12, 'did we increase number of elements';
    is @a.end,   11, 'did we increase the last index';
    is @a[0],   999, 'did we get the right value after .prepend I';
    is @a[1],  1000, 'did we get the right value after .prepend II';

    @a.shift for ^3;
    is @a.elems,  9, 'did we decrease number of elements';
    is @a.end,    8, 'did we decrease the last index';
}, 'test .unshift / .prepend / .shift one flattenable element';

subtest {
    plan 12;
    is-deeply @a.unshift(42,666), @a, 'did .unshift return self';
    is @a.elems, 11, 'did we increase number of elements';
    is @a.end,   10, 'did we increase the last index';
    is @a[0],    42, 'did we get the right value after .unshift I';
    is @a[1],   666, 'did we get the right value after .unshift II';

    is-deeply @a.prepend(999,1000), @a, 'did .prepend return self';
    is @a.elems, 13, 'did we increase number of elements';
    is @a.end,   12, 'did we increase the last index';
    is @a[0],   999, 'did we get the right value after .prepend I';
    is @a[1],  1000, 'did we get the right value after .prepend II';

    @a.shift for ^4;
    is @a.elems,  9, 'did we decrease number of elements';
    is @a.end,    8, 'did we decrease the last index';
}, 'test .unshift / .append / .shift multiple elements';

subtest {
    plan 35;
    my @b is MyArray;
    is (@b[4] = 42), 42, 'does assignment pass on the value';
    is-deeply @b[$_]:exists, False, "does element $_ not exist" for ^4;
    is-deeply @b[$_]:exists, False, "does element $_ not exist" for 5..10;
    is @b[4], 42, 'did the right value get assigned';
    is @b.elems, 5, 'did we get right number of elements initially';
    is @b.end,   4, 'did we get right last element initially';

    is @b.shift, Any, 'did we get the right 0th element';
    is @b.elems, 4, 'did we get right number of elements after shift';
    is @b.end,   3, 'did we get right last element after shift';
    is-deeply @b[4]:exists, False, 'did the last element disappear';
    is-deeply @b[$_]:exists, False, "does element $_ still not exist" for ^3;
    is @b[3], 42, 'did the right value move down one';

    is-deeply @b.unshift(666), @b, 'does unshift return self';
    is @b[0], 666, 'did the right value get unshifted';
    is-deeply @b[$_]:exists, False, "does element $_ not exist" for 1 .. 3;
    is-deeply @b[$_]:exists, False, "does element $_ not exist" for 5..10;
    is @b.elems, 5, 'did we get right number of elements after unshift';
    is @b.end,   4, 'did we get right last element after unshift';
}, 'test holes in arrays';

# vim: ft=perl6 expandtab sw=4
