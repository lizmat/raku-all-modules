use v6.c;

use Test;
use XML::XPath;

plan 6;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<root att="root_att">
   <daughter att="3"/>
   <daughter att="4"/>
   <daughter att="5"/>
</root>
ENDXML

# my %results= ( '/root/daughter[@att<"4"]' => 'daughter[3]',
#                '/root/daughter[@att<4]'   => 'daughter[3]',
#                '//daughter[@att<4]'       => 'daughter[3]',
#                '/root/daughter[@att>4]'   => 'daughter[5]',
#                '/root/daughter[@att>5]'   => '',
#                '/root/daughter[@att<3]'   => '',
#              );
is $x.find('/root/daughter[@att<"4"]').attribs<att> , 3;
is $x.find('/root/daughter[@att<4]').attribs<att> , 3;
is $x.find('//daughter[@att<4]').attribs<att> , 3;
is $x.find('/root/daughter[@att>4]').attribs<att> , 5;

is $x.find('/root/daughter[@att>5]'), (Nil);
is $x.find('/root/daughter[@att<3]'), (Nil);

done-testing;
