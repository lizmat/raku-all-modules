use v6.c;

use Test;
use XML::XPath;

my $x   = XML::XPath.new(xml => '<a><bar/>yada yada<bar/></a>');
my $lnk = $x.find('//a', :to-list);
my @t   = $x.find('//text()', :start($lnk[0]), :to-list);

is @t.elems, 1, 'found one element';
is @t[0].text, 'yada yada', 'found yada yada';

done-testing;

