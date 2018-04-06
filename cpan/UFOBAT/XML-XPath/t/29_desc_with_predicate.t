use v6.c;

use Test;
use XML::XPath;

plan 4;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB>OK</BBB>
<CCC/>
<BBB/>
<DDD><BBB/></DDD>
<CCC><DDD><BBB/><BBB>NOT OK</BBB></DDD></CCC>
</AAA>
ENDXML

my $set;
$set = $x.find('/descendant::BBB[1]');
isa-ok $set, XML::Element, 'found one node';

is $set.nodes.elems, 1, 'one child';
isa-ok $set.nodes[0], XML::Text, 'child is a text node';
is $set.nodes[0].Str, 'OK', 'it is OK';

done-testing;
