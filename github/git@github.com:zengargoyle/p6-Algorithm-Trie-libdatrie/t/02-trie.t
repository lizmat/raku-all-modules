use v6;
use Test;
use Algorithm::Trie::libdatrie;

my Str @words = < pool prize preview prepare produce progress >;

my Trie ($t, $n);

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
# .retrieve
#

my $data;

$data = $t.retrieve('preview');
is ?$data, True, 'got data';
is $data, 2, 'data value is correct';

$data = $t.retrieve('bogus');
is ?$data, False, 'got no data';

#
# .delete
#

ok $t.delete('preview'), 'deleted an entry';
$data = $t.retrieve('preview');
is ?$data, False, 'and it is gone';

nok $t.delete('preview'), 'duplicate delete fails';

#
# .save
# .new from file
#

use File::Temp;
my ($fn, $fh) = tempfile :unlink;
ok $t.save($fn), "saved trie to file '$fn'";
ok $n.=new($fn), "loaded trie from file '$fn'";

$data = $n.retrieve('pool');
is ?$data, True, 'got data';
is $data, 0, 'data value is correct';

done-testing;
