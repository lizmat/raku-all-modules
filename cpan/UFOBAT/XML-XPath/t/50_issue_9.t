use v6.c;

use Test;
use XML::XPath;

my $x   = XML::XPath.new(xml => '<a>link desc<bar/>yada yada<bar/></a>');
my $lnk = $x.find('//a', :to-list);
my @t   = $x.find('//text()', :start($lnk[0]), :to-list);

is @t.elems, 2, 'found two element';
is @t[0].text, 'link desc', 'found link desc';
is @t[1].text, 'yada yada', 'found yada yada';

done-testing;

