use v6.c;

use Test;
use XML::XPath;

plan 8;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB id="first"/>
<BBB/>
<BBB/>
<BBB id="last"/>
</AAA>
ENDXML

my $set;
$set = $x.find('/AAA/BBB[1]');
does-ok $set, XML::Node, 'found one node';
is $set.name, 'BBB', 'node name is BBB';
is $set.attribs<id>, 'first', 'right node is selected';

$set = $x.find('/AAA/BBB[1]/@id');
isa-ok $set, Str, 'found one node';
is $set, 'first', 'node attrib is first';

$set = $x.find('/AAA/BBB[ last() ]');
does-ok $set, XML::Node, 'found one node';
is $set.name, 'BBB', 'node name is BBB';
is $set.attribs<id>, 'last', 'right node is selected';

done-testing;
