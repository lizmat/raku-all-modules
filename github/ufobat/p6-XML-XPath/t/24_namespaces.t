use v6.c;

use Test;
use XML::XPath;

plan 9;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<xml xmlns:foo="foobar.example.com"
    xmlns="flubber.example.com">
    <foo>
        <bar/>
        <foo/>
    </foo>
    <foo:foo>
        <foo:foo/>
        <foo:bar/>
        <foo:bar/>
        <foo:foo/>
    </foo:foo>
    <attr:node xmlns:attr="attribute.example.com"
        attr:findme="someval"/>
</xml>
ENDXML

# Don't set namespace prefixes - uses element context namespaces
my $set;

$set = $x.find('//foo:foo');
is $set.elems, 3, 'found 3 nodes';

$set = $x.find('//goo:foo', :to-list(True));
is $set.elems, 0, 'found 0 nodes';

$set = $x.find('//foo');
is $set.elems, 2, 'found 2 nodes';

$set = $x.find('//*');
is $set.elems, 10, 'found 10 nodes';

$set = $x.find('//foo:*');
is $set.elems, 5, 'found 5 nodes with the ns foo';

$set = $x.find('//@attr:*');
is $set.elems, 1, 'found one attribute';

# Set namespace prefixes
$x.set-namespace: 'foo' => "flubber.example.com";
$x.set-namespace: 'goo' => "foobar.example.com";

# should find flubber.com foos
$set = $x.find('//foo:foo');
is $set.elems, 2, 'found 2 nodes';

# should find foobar.com foos
$set = $x.find('//goo:foo');
is $set.elems, 3, 'found 3 nodes';

# should find default NS foos
$set = $x.find('//foo');
is $set.elems, 2, 'found 2 nodes';

done-testing;
