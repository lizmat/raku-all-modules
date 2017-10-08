use v6;
use Test;
use Algorithm::Trie::libdatrie;

my Str @words = < pool prize preview prepare produce progress >;

my Trie $t;

#
# .new with character map
#

$t .= new: 'a'..'z';
isa-ok $t, Trie, 'got a Trie';

#
# .store
#

for @words.kv -> $index, $word {
  state $ok;
  $ok += 1 if $t.store: $word, $index;
  LAST { is $ok, @words.elems, "added @words.elems() words" }
}

#
# .root
#

my TrieState $s = $t.root;
isa-ok $s, TrieState, 'got TrieState';

ok $s.is-walkable('p'), "can walk to 'p'";
ok $s.walk('p'), "walked to 'p'";
is $s.walkable-chars.Set, <o r>.Set, "can walk to 'o','r'";

my TrieState $r = $s.clone;
isa-ok $r, TrieState, "made a clone at 'p'";
ok $r.walk('o'), "walked to 'o'";
ok $r.is-single, "state at 'o' is single";
ok $r.walk('o'), "walked to 'o'";
ok $r.walk('l'), "walked to 'l'";
ok $r.is-terminal, "state at 'pool' is terminal";
is $r.value, 0, "got data at 'pool'";

# re-clone
$r = $s.clone;
isa-ok $r, TrieState, "made another clone at 'p'";
ok $r.walk('r'), "walked to 'r'";
is $r.walkable-chars.Set, <e i o>.Set, "can walk to 'e', 'i', 'o'";
ok $r.walk('i'), "walked to 'i'";
ok $r.walk('z'), "walked to 'z'";
ok $r.is-single, "state at 'priz' is single";
ok $r.walk('e'), "walked to 'e'";
ok $r.is-terminal, "state at 'prize' is terminal";
is $r.value, 1, "got data at 'prize'";

#
# can also iterate
#

my TrieIterator $i = TrieIterator.new: $s;
isa-ok $i, TrieIterator, "creating an iterator at 'p'";

while $i.next {
  state @tails;
  @tails.push: $i.key;
  LAST {
    is @tails, <ool repare review rize roduce rogress>.Array,
      "got tails through iteration";
  }
}

done-testing;
