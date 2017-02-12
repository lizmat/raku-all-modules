use v6.c;

use Test;
use XML::XPath;

plan 2;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<page></page>
ENDXML

my $set;
my $root = $x.find('/.');
isa-ok $root, XML::Element, 'found one node';

my $doc = $x.find('/..');
nok $doc.defined, 'nothing found';

done-testing;
