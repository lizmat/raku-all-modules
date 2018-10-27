use lib 'lib';
use HTML::MyHTML;

my $html = "<div><span>HTML</span></div>";

# init
my HTML::MyHTML $parser .= new;

# parse
$parser.parse($html);

# print tree
$parser.tree.print($parser.tree.document):i;

# print span text
$parser.tree.nodes('span')[0].child.text.say;

# dispose
$parser.dispose;
