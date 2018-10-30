unit class HTML::MyHTML::Node;

use HTML::MyHTML::Raw;
use HTML::MyHTML::Encoding;

has $.raw;
has Tree $!tree;

method create(:$tree, :$tag, :$ns) {
  self.bless(:raw(myhtml_node_create($tree, $tag, $ns)) :$tree)
}

method next   { self.bless(:raw(myhtml_node_next($!raw))   :$!tree) }

method prev   { self.bless(:raw(myhtml_node_prev($!raw))   :$!tree) }

method parent { self.bless(:raw(myhtml_node_parent($!raw)) :$!tree) }

multi method child(:$last) {
  $last
    ?? self.bless(:raw(myhtml_node_last_child($!raw)) :$!tree)
    !! self.bless(:raw(myhtml_node_child($!raw))      :$!tree)
}

multi method child(Int $idx where 0, :$last) { self.child(:$last) }

multi method child(UInt $idx) {
  my $cursor = myhtml_node_child($!raw);
  for ^$idx { $cursor = myhtml_node_next($cursor) }
  return self.bless(:raw($cursor) :$!tree);
}

multi method child(Int $idx where * < 0) {
  my $cursor = myhtml_node_last_child($!raw);
  for ^$idx { $cursor = myhtml_node_prev($cursor) }
  return self.bless(:Raw($cursor) :$!tree);
}

method free { myhtml_node_free($!tree, $!raw) }

method remove { myhtml_node_remove($!raw) }

method delete(Bool :r(:rec(:$recursive))) {
  not $recursive
    ?? myhtml_node_delete($!tree, $!raw)
    !! myhtml_node_delete_recursive($!tree, $!raw);
}

multi method text() {
  myhtml_node_text($!raw)
}
multi method text($new) {
  my Blob $b = $new.encode;
  myhtml_node_text_set($!tree, $!raw, $b, $b.bytes, Enc<UTF-8>);
}

method Str { myhtml_string_data(myhtml_node_string($!raw)) }
