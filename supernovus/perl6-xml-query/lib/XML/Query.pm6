use XML;

class XML::Query;

use XML::Query::Statement;

has $.xml;
has $.class-attr = 'class';

multi method new (XML::Element $xml, *%opts)
{
  self.new(:$xml, |%opts);
}

multi method new (XML::Document $doc, *%opts)
{
  my $xml = $doc.root;
  self.new(:$xml, |%opts);
}

method compile ($statement)
{
  XML::Query::Statement.new(:$statement, :parent(self));
}

method apply ($statement)
{
  self.compile($statement).apply($!xml);
}

method AT_KEY ($statement)
{
  self.apply($statement.join(' '));
}

method postcircumfix:<( )> ($statement)
{
  self.apply($statement.join(','));
}

