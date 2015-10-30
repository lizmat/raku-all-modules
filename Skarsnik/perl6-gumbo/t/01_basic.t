use v6;
use Gumbo;
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

plan 4;


my $xmldoc = parse-html($html);

ok $xmldoc ~~ XML::Document, "Return a XML::Document";
ok $xmldoc.root.name eq "html", "Root element is html";
ok $xmldoc.root.elements[0].elements[0][0] ~~ XML::Text, "Found text";
ok $xmldoc.root.elements(:TAG<title>, :RECURSE<3>)[0][0].text eq "Fancy", "Title is Fancy";


