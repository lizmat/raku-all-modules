use v6.c;

use Test;
use XML::XPath;

plan 1;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<xml xmlns="foobar.example.com">
    <foo>
        <bar/>
        <foo/>
    </foo>
</xml>
ENDXML

my $nodes = $x.find("//*[ namespace-uri() = 'foobar.example.com' ]");
is $nodes.elems, 4, 'found 4 nodes';

done-testing;
