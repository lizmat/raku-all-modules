use v6.c;

use Test;
use XML::XPath;

plan 3;

my $set;
my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<Q/>
<Q/>
<Q/>
<SSSS/>
<BB/>
<CCC/>
<DDDDDDDD/>
<EEEE/>
</AAA>
ENDXML

$set = $x.find('//*[ string-length(name()) = 3 ]');
is $set.elems, 2, 'found 2 text nodes';

$set = $x.find('//*[ string-length(name()) < 3 ]');
is $set.elems, 4, 'found 2 text nodes';

$set = $x.find('//*[ string-length(name()) > 3 ]');
is $set.elems, 3, 'found 2 text nodes';#

done-testing;
