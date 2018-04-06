use v6.c;

use Test;
use XML::XPath;

plan 3;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<foo num="foo" />
ENDXML

is $x.find('substring-before("1999/04/01","/")'), '1999';
is $x.find('substring-before(/foo/@num,"o")'), 'f';
is $x.find('substring-before("1999/04/01","?")'), '';

done-testing;
