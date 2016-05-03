use v6;
use Test;

use HTML::MyHTML::Raw;

my $html = "<div><span>HTML</span></div>";

# basic init
my $myhtml = myhtml_create();
is 0, myhtml_init($myhtml, PARSE_MODE_DEFAULT, 1, 4096),
  "Init returns STATUS_OK";

# init tree
my $tree = myhtml_tree_create();
is 0, myhtml_tree_init($tree, $myhtml),
  "Tree init returns STATUS_OK";

# parse html
is 0, myhtml_parse_fragment($tree, 0, $html.encode, $html.encode.bytes, 0x02a, 0x01),
  "Basic parsing returns STATUS_OK";

# release resources
nok myhtml_tree_destroy($tree).defined, "Destroys tree";
nok myhtml_destroy($myhtml).defined, "Destroys parser";

done-testing;
