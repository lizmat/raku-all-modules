unit class HTML::MyHTML::Collection does Positional;

use HTML::MyHTML::Raw;

use HTML::MyHTML::Node;
use HTML::MyHTML::Status;
use HTML::MyHTML::Tag;

has Collection $.raw;
has Tree $!tree;

method new($raw, :$tree) { self.bless(:$raw, :$tree) }

submethod BUILD(:$!raw, :$!tree) {}

method elems { $!raw.length }

method bytes { $!raw.size }

method AT-POS($n) {
  HTML::MyHTML::Node.new(:raw($!raw.list[$n]) :$!tree)
}

method EXISTS-POS($n) { $!raw.list[$n]:exists }

method clean { myhtml_collection_clean($!raw) }

method dispose { myhtml_collection_destroy($!raw) }

method upto(Int $n) {
  my $status = myhtml_collection_check_size($!raw, $n);
  given $status {
    when $_ ~~ MyHTML_STATUS_ERROR_MEMORY_ALLOCATION {
      warn 'myhtml_collection_check_size returned a memory allocation error.';
      return False
    }
    when $_ ~~ MyHTML_STATUS_OK { return True }
    default { return False }
  }
}

method add(Str $tag is rw) {
  my $status; $!raw = do if Tag.{$tag}:exists {
    myhtml_get_nodes_by_tag_id($!tree, $!raw, Tag.{$tag}, $status);
  } else {
    $tag .= encode;
    myhtml_get_nodes_by_name($!tree, $!raw, $tag, $tag.bytes, $status);
  }
  $status == 0 ?? return self !! return $status;
}
