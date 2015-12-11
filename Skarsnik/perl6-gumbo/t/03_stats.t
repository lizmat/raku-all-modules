use v6;
use Gumbo::Parser;
use Test;

my $html = q:to/END_HTML/;
<html>
<head>
	<title>Fancy</title>
</head>
<body>
	<p>It's fancy</p>
</body>
</html>

END_HTML

plan 8;

my $parser = Gumbo::Parser.new;
my $xmldoc = $parser.parse($html);

ok $xmldoc ~~ XML::Document, "Return a XML::Document";
ok $parser.stats<whitespaces> eq 5, "There must be 5 whitespaces";
ok $parser.stats<elements> eq 5, "There must be 5 xml::elements";
ok $parser.stats<xml-objects> eq 5 + 5 + 2, "There must be 12 xml objects total";

$xmldoc = $parser.parse($html, :nowhitespace(True));

ok $parser.stats<xml-objects> eq 5 + 2, "Without whitespace only 7 xml objects";


$xmldoc = $parser.parse($html, :TAG<p>, :nowhitespace(True));

ok $xmldoc.root[0].name eq "p", "We should have <p>";
ok $parser.stats<xml-objects> eq 3, "Only a <p> and <html> make for 3 xml objects";
ok $parser.stats<elements> eq 2, "Only a <p> and <html> make for 2 xml elements";

