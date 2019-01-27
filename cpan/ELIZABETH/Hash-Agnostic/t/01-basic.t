use v6.c;
use Test;

use Hash::Agnostic;

class MyHash does Hash::Agnostic {
    has %!hash;

    method AT-KEY($key)          is raw { %!hash.AT-KEY($key)         }
    method BIND-KEY($key,\value) is raw { %!hash.BIND-KEY($key,value) }
    method EXISTS-KEY($key)             { %!hash.EXISTS-KEY($key)     }
    method DELETE-KEY($key)             { %!hash.DELETE-KEY($key)     }
    method keys()                       { %!hash.keys                 }
}

plan 8;

my @keys   := <a b c d e f g h>;
my @values := 42, 666, 314, 628, 271, 6, 7, 8;
my @sorted := @values.sort.List;
my @pairs  := (@keys Z=> @values).List;
my @kv     := (@keys Z @values).flat.List;

my %h is MyHash = @pairs;
sub test-basic() {
    subtest {
        is %h.elems, +@keys, "did we get {+@keys} elements";
        is %h.gist,
          '{a => 42, b => 666, c => 314, d => 628, e => 271, f => 6, g => 7, h => 8}',
          'does .gist work ok';
        is %h.Str,
          'a	42 b	666 c	314 d	628 e	271 f	6 g	7 h	8',
          'does .Str work ok';
        is %h.perl,
          'MyHash.new(:a(42),:b(666),:c(314),:d(628),:e(271),:f(6),:g(7),:h(8))',
          'does .perl work ok';
    }, 'test basic stuff after initialization';
}

test-basic;

subtest {
    plan +@keys;
    my %test = @pairs;
    is %test{.key}, .value, "did iteration {.key} produce %test{.key}"
      for %h;
}, 'checking iterator';

subtest {
    plan +@keys;
    my %test = @pairs;
    is %h{$_}, %test{$_}, "did key $_ produce %test{$_}"
      for @keys;
}, 'checking {x}';

subtest {
    plan 4;
    ok %h<g>:exists, 'does "g" exist';
    is %h<g>:delete, 7, 'does :delete work on "g"';
    nok %h<g>:exists, 'does element no longer exist';
    is %h.elems, @keys - 1, 'do we have one element less now: elems';
}, 'deletion of key';

subtest {
    plan 4;
    is-deeply %h<d e f>:exists, (True,True,True),
      'can we check existence of an existing slice';
    is-deeply %h<d e f>:delete, (628,271,6),
      'can we remove an existing slice';
    is-deeply %h<d e f>:exists, (False,False,False),
      'can we check existence of an non-existing slice';
    is %h.elems, @keys - 4, 'did we keep update number of elements';
}, 'can we delete a slice';

subtest {
    plan 3;
    is-deeply (%h{@keys}:v).sort, (8,42,314,666), 'does a value slice work';
    is-deeply (%h{}:v).sort, (8,42,314,666), 'does a value zen-slice work';
    is-deeply (%h{*}:v).sort, (8,42,314,666), 'does a value whatever-slice work';
}, 'can we do value slices';

%h = @pairs;
test-basic;

subtest {
    plan 4;
    is-deeply %h.keys.sort,            @keys, 'does .keys work';
    is-deeply %h.values.sort,        @sorted, 'does .values work';
    is-deeply %h.pairs.sort( *.key ), @pairs, 'does .pairs work';
    is-deeply %h.kv.sort,           @kv.sort, 'does .kv work';
}, 'check iterator based methods';

# vim: ft=perl6 expandtab sw=4
