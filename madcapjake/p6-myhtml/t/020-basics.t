use v6;
use Test;

use HTML::MyHTML::NativeCall;

my str $html = "<div><span>HTML</span></div>";

my MyHTML $myhtml   .= new(MyHTML_OPTIONS_DEFAULT, 1, 0);
my MyHTMLTree $tree .= new($myhtml);

is 0, $myhtml.parse($tree, $html), 'parsing returns successful exit code';

$tree.dispose;
$myhtml.dispose;

done-testing;
