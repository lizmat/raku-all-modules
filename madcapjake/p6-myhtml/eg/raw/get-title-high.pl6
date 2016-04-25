use v6.c;
use lib 'lib';

use HTML::MyHTML::Raw;
use HTML::MyHTML::Tag;
use HTML::MyHTML::Encoding;

# basic init
my $myhtml = myhtml_create();
myhtml_init($myhtml, 0, 1, 0);

# init tree
my $tree = myhtml_tree_create();
myhtml_tree_init($tree, $myhtml);

# gather some html
my $website = qx{curl -s http://www.example.com}.encode;

# parse html
myhtml_parse($tree, Enc<utf-8>, $website, $website.bytes);

# collect title tags
my $collection = myhtml_get_nodes_by_tag_id($tree, Collection, Tag<title>, 0);

with $collection {
  my $text-node = myhtml_node_child($_.list[0]);
  with $text-node {
    my Str $text = myhtml_node_text($_);
    with $text { say "Title: $text" }
  }
}

myhtml_collection_destroy($collection);
myhtml_tree_destroy($tree);
myhtml_destroy($myhtml);
