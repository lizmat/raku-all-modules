use v6.c;
use lib 'lib';

use HTML::MyHTML;

# basic init
my HTML::MyHTML $parser .= new;

my $div = "<div><p>leave this text alone</p>text for manipulate </div>";

# parse html
$parser.parse($div);

# print original tree
"Original Tree:".say;
$parser.tree.print($parser.tree.document):e;

'Change word: manipulate => test'.say;

my @collection := $parser.tree.nodes('div');
unless @collection.elems <= 0 {
  @collection.elems.say;
  my $text-node = @collection[0].child(0).child;
  say $text-node.text;
  say $text-node.Str; # still not sure what the diff is...
  $text-node.text($text-node.text.subst('leave', 'edit'));
  say $text-node.text;
  say $text-node.Str;
}

# print modified tree
"Modified Tree:".say;
$parser.tree.print($parser.tree.document):e;

$parser.dispose;
