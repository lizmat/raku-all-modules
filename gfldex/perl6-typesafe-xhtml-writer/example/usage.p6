{
	use v6;
	use Typesafe::XHTML::Writer :ALL;

	put html( xml-lang=>'de',
	body(
		div( id=>"uniq",
		p( class=>"abc", 'your text here'),
		p( 'more text' ),
		'<p>this will be quoted with &lt; and &amp;</p>'
	)
));

put span('<b>this will also be quoted with HTML-entities</b>');
}
{
	use v6;
	use Typesafe::XHTML::Writer :p, :title, :style;
	use Typesafe::XHTML::Skeleton;

	put xhtml-skeleton(p('Hello Camelia!', class=>'foo'), 'Camelia can quote all the <<<< and &&&&.', header=>(title('Hello Camelia'), style('p.foo { color: #fff; }' )));
}
{
	use v6;
	use Typesafe::HTML;
	use Typesafe::XHTML::Writer :p;
	use Typesafe::XHTML::Skeleton;

	my $inject = '<script src="http://dr.evil.ord/1337.js></script>';
	put xhtml-skeleton(p('Hello Camelia!') ~ $inject);
}
