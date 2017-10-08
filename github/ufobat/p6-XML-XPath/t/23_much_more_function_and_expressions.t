use v6.c;

use Test;
use XML::XPath;

plan 3;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
    <BBB/>
    <BBB/>
    <BBB/>
    <BBB/>
    <BBB/>
    <BBB/>
    <BBB/>
    <BBB/>
    <CCC/>
    <CCC/>
    <CCC/>
</AAA>
ENDXML

my $set;
$set = $x.find('//BBB[position()mod2=0]');
is $set.elems, 4, 'found 4 nodes';

$set = $x.find('//BBB[position()=floor(last()div2+0.5)orposition()=ceiling(last()div2+0.5)]');
is $set.elems, 2, 'found 2 nodes';

$set = $x.find('//CCC[position()=floor(last()div2+0.5)orposition()=ceiling(last()div2+0.5)]');
is $set.elems, 1, 'found 1 nodes';


done-testing;
