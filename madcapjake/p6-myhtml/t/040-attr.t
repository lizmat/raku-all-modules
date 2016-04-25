use v6;
use Test;

use HTML::MyHTML;
use HTML::MyHTML::Tag;

my Str $html = '<div></div>';

# init
my $myhtml = MyHTML.new(MyHTML_OPTIONS_DEFAULT, 1, 0);
my $tree = MyHTMLTree.new($myhtml);

# parse html
$myhtml.parse($tree, $html, :fragment, :tag(MyHTML_TAG_DIV), :ns(MyHTML_NAMESPACE_HTML));

# get first DIV from index
my $tag-index = $tree.tag-index;
my $index-node = $tag-index.first-node(MyHTML_TAG_DIV);
my $node = $tree.tag-index.tree-node($index-node);

# print original tree
say "Original Tree:";
$tree.print($node, $*OUT, :tree, :pretty(1));
