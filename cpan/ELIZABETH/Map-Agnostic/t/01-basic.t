use v6.c;
use Test;

use Map::Agnostic;

class MyMap does Map::Agnostic {
    has %!hash;

    method AT-KEY(\key)          { %!hash.AT-KEY(key)           }
    method INIT-KEY(\key,\value) { %!hash.BIND-KEY(key,value<>) }
    method EXISTS-KEY(\key)      { %!hash.EXISTS-KEY(key)       }
    method keys()                { %!hash.keys                  }
}

plan 7;

my @keys   := <a b c d e f g h>;
my @values := 42, 666, 314, 628, 271, 6, 7, 8;
my @sorted := @values.sort.List;
my @pairs  := (@keys Z=> @values).List;
my @kv     := (@keys Z @values).flat.List;

my %m is MyMap = @pairs;
sub test-basic() {
    subtest {
        is %m.elems, +@keys, "did we get {+@keys} elements";
        is %m.gist,
          '{a => 42, b => 666, c => 314, d => 628, e => 271, f => 6, g => 7, h => 8}',
          'does .gist work ok';
        is %m.Str,
          'a	42 b	666 c	314 d	628 e	271 f	6 g	7 h	8',
          'does .Str work ok';
        is %m.perl,
          'MyMap.new(:a(42),:b(666),:c(314),:d(628),:e(271),:f(6),:g(7),:h(8))',
          'does .perl work ok';
    }, 'test basic stuff after initialization';
}

test-basic;

subtest {
    plan +@keys;
    my %test = @pairs;
    is %test{.key}, .value, "did iteration {.key} produce %test{.key}"
      for %m;
}, 'checking iterator';

subtest {
    plan +@keys;
    my %test = @pairs;
    is %m{$_}, %test{$_}, "did key $_ produce %test{$_}"
      for @keys;
}, 'checking {x}';

subtest {
    plan 4;
    ok %m<g>:exists, 'does "g" exist';
    dies-ok { %m<g>:delete }, 'does :delete NOT work on "g"';
    ok %m<g>:exists, 'does element still exist';
    is %m.elems, +@keys, 'do we have same number of elems: elems';
}, 'attempt deletion of key';

subtest {
    plan 4;
    is-deeply %m<d e f>:exists, (True,True,True),
      'can we check existence of an existing slice';
    dies-ok { %m<d e f>:delete, (628,271,6) },
      'can we NOT remove an existing slice';
    is-deeply %m<d e f>:exists, (True,True,True),
      'can we check existence of still existing slice';
    is %m.elems, +@keys, 'did we NOT update number of elements';
}, 'can we NOT delete a slice';

subtest {
    plan 3;
    is-deeply (%m{@keys}:v).sort, (6,7,8,42,271,314,628,666),
      'does a value slice work';
    is-deeply (%m{}:v).sort, (6,7,8,42,271,314,628,666),
      'does a value zen-slice work';
    is-deeply (%m{*}:v).sort, (6,7,8,42,271,314,628,666),
      'does a value whatever-slice work';
}, 'can we do value slices';

dies-ok { %m = @pairs }, 'cannot re-initialize a Map';

# vim: ft=perl6 expandtab sw=4
