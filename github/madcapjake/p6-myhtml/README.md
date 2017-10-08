# HTML::MyHTML

A wrapper for [MyHTML](http://lexborisov.github.io/myhtml/) an HTML parser.

## Usage
First you need to [install](https://github.com/lexborisov/myhtml#build-and-installation) MyHTML. Then install this module via:
```
panda install HTML::MyHTML
```
```
zef install HTML::MyHTML
```
### Example
#### HTML::MyHTML
```perl6
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
```
#### HTML::MyHTML::Raw
```perl6
use HTML::MyHTML::Raw;
use HTML::MyHTML::Encoding;

my $html = "<div><span>HTML</span></div>".encode;

# basic init
my $myhtml = myhtml_create();
myhtml_init($myhtml, 0, 1, 0);

# first tree init
my $tree = myhtml_tree_create();
myhtml_tree_init($tree, $myhtml);

# parse html
myhtml_parse($tree, Enc<utf-8>, $html, $html.bytes);

# release resources
myhtml_tree_destroy($tree);
myhtml_destroy($myhtml);
```
