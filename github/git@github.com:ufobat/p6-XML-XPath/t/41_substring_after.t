use v6.c;

use Test;
use XML::XPath;

plan 4;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<foo num="foo" />
ENDXML

is $x.find('substring-after("1999/04/01","/")'), '04/01';
is $x.find('substring-after("1999/04/01","19")'), '99/04/01';
is $x.find('substring-after("1999/04/01","2")'), '';
is $x.find('substring-after(/foo/@num,"x")'), '';

done-testing;
