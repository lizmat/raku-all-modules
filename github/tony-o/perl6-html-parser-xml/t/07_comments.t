use HTML::Parser::XML;
use XML::Comment;
use Test;
use lib 'lib';

my $html = q:to/END_HTML/;
<html>
  <body>
    <table>
	<!-- Comment1 <tr>
        <td>first</td>
      </tr> -->
      <!-- It actually the first element -->
      <tr>
        <td>second</td>
      </tr>
    </table>
    <!--Text-->
    <p>Some Text</p>
  </body>
</html>
END_HTML

my $parser = HTML::Parser::XML.new;
$parser.parse($html);
my $xmldoc = $parser.xmldoc;

plan 5;

my $table = $xmldoc.elements(:TAG<table>, :RECURSE<3>)[0];

ok $table[0] ~~ XML::Comment, "First sub element on table is a comment";
ok $table[1] ~~ XML::Comment, "The second element of the table is also a comment"; 

my $td = $table.elements(:TAG<td>, :RECURSE<3>)[0];

ok $td[0].text eq 'second', "The first real cell of the table is 'second'";

ok $xmldoc.root[1][2] ~~ XML::Comment, "<--I did not put space after <-- tag";
ok $xmldoc.root[1][2].data eq 'Text', "We get the right content for a <--Text--> comment";
