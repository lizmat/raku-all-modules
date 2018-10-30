use v6.c;

use Test;
use XML::XPath;

plan 2;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB/>
<CCC/>
<DDD><CCC/></DDD>
<EEE/>
</AAA>
ENDXML

my $one-set;
my $other-set;
$one-set   = $x.find('/child::AAA');
$other-set = $x.find('/AAA');

is-deeply($one-set, $other-set, 'explicit axis child test');

$one-set   = $x.find('/child::AAA/child::BBB');
$other-set = $x.find('/AAA/BBB');

is-deeply($one-set, $other-set, 'explicit axis child test');

done-testing;
