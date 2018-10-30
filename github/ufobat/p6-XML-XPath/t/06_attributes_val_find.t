use v6.c;

use Test;
use XML::XPath;

plan 6;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB id='b1'/>
<BBB name=' bbb '/>
<BBB name='bbb'/>
</AAA>
ENDXML

my $set;
$set = $x.find('//BBB[ @id = "b1" ]');
does-ok $set, XML::Node, 'found one node';
is $set.name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[ @name = "bbb" ]', :to-list(True));
is $set.elems, 1 , 'found one attrib';
is $set[0].name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[ normalize-space(@name) = "bbb" ]');
is $set.elems, 2 , 'found one node';
is $set[0].name, 'BBB', 'node name is BBB';

done-testing;
