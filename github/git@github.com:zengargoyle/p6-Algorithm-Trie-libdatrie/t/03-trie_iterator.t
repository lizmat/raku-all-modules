use v6;
use Test;
use Algorithm::Trie::libdatrie;

my Str @words = < pool prize preview prepare produce progress >;
# NOTE: key is value, data is key
my Str @ordered_k = @words.pairs.sort(*.value).map(*.value);
my Int @ordered_d = @words.pairs.sort(*.value).map(*.key);

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
# .iterator
#

my TrieIterator $i = $t.iterator;
isa-ok $i, TrieIterator, 'got a TrieIterator';

while $i.next {
  state (@keys, @values);
  @keys.push: $i.key;
  @values.push: $i.value;
  LAST {
    # .Array to make context the same
    is-deeply @keys.Array, @ordered_k.Array, 'got keys in order';
    is-deeply @values.Array, @ordered_d.Array, 'got values in same order';
  }
}

done-testing;
