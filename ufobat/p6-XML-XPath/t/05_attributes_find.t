use v6.c;

use Test;
use XML::XPath;

plan 10;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB id='b1'/>
<BBB id='b2'/>
<BBB name='bbb'/>
<BBB />
</AAA>
ENDXML

my $set;
$set = $x.find('//BBB[ @id ]');
is $set.elems, 2 , 'found one node';
is $set[0].name, 'BBB', 'node name is BBB';
is $set[1].name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[ @name ]');
does-ok $set, XML::Node, 'found one node';
is $set.name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[ @* ]');
is $set.elems, 3 , 'found 3 node';
is $set[0].name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[ not( @* ) ]');
say $set;
does-ok $set, XML::Node, 'found one node';
is $set.name, 'BBB', 'node name is BBB';
is $set.attribs.elems, 0, 'and node really has no attribute';

done-testing;
