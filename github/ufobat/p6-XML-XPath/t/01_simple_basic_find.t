use v6.c;

use Test;
use XML::XPath;

plan 7;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
    <BBB/>
    <CCC/>
    <BBB/>
    <CCC/>
    <BBB/>
    <!-- comment -->
    <DDD>
        <BBB/>
        Text
        <BBB/>
    </DDD>
    <CCC/>
</AAA>
ENDXML

my $set;
$set = $x.find("/");
isa-ok $set, XML::Document, 'found one node';

$set = $x.find("/AAA");
does-ok $set, XML::Node, 'found one node';
is $set.name, 'AAA', 'node name is AAA';

$set = $x.find("/AAA/BBB");
is $set.elems, 3 , 'found three nodes';
is $set[0].name, 'BBB', 'node name is BBB';

$set = $x.find("/AAA/DDD/BBB");
is $set.elems, 2 , 'found 2 nodes';
is $set[0].name, 'BBB', 'node name is BBB';

done-testing;
