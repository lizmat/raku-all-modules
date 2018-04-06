use v6.c;

use Test;
use XML::XPath;

plan 2;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB>
    <CCC/>
    <ZZZ>
        <DDD/>
        <DDD>
            <EEE/>
        </DDD>
    </ZZZ>
    <FFF>
        <GGG/>
    </FFF>
</BBB>
<XXX>
    <DDD>
        <EEE/>
        <DDD/>
        <CCC/>
        <FFF/>
        <FFF>
            <GGG/>
        </FFF>
    </DDD>
</XXX>
<CCC>
    <DDD/>
</CCC>
</AAA>
ENDXML

my $set;
$set = $x.find('/AAA/XXX/following::*');
is $set.elems, 2 , 'found 2 nodes';

$set = $x.find('//ZZZ/following::*');
is $set.elems, 12 , 'found 2 nodes';

done-testing;
