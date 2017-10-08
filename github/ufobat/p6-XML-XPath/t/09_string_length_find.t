use v6.c;

use Test;
use XML::XPath;

plan 13;

my $x;
my $set;

$x = XML::XPath.new(xml => q:to/ENDXML/);
<doc><para>para one</para></doc>
ENDXML

$set = $x.find('/doc/text()');
nok $set.defined, 'nothing found';
#isa-ok $set, XML::XPath::Result ,'nothing found';

$set = $x.find('string-length( /doc/text() )');
nok $set.defined, 'nothing found';

$x = XML::XPath.new(xml => q:to/ENDXML/);
<doc>
  <para>para one has <b>bold</b> text</para>
</doc>
ENDXML


$set = $x.find('/doc/text()');
is $set.elems, 2, 'found 2 text nodes';

# XML trimms the nodes, thats why the $set[0].Str is not giving the right result
is $set[0].text, "\n  ", 'first text is correct';
is $set[1].text, "\n", 'first text is correct';



$set = $x.find('string-length( /doc/text() )');
is $set.elems, 2, 'found 2 text nodes';
is $set[0], 1, 'XML trimmed string length is 1';
is $set[1], 1, 'XML trimmed string length is 1';

$set = $x.find('/doc/para/text()');
is $set.elems, 2, 'found 2 text nodes';
is $set[0].text, "para one has ", 'first text is correct';
is $set[1].text, " text", 'first text is correct';

$set = $x.find('string-length( /doc/para/text() )');
is $set[0], 13, 'XML trimmed string length is 1';
is $set[1], 5, 'XML trimmed string length is 1';

done-testing;
