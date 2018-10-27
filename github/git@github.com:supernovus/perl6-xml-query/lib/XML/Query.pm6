use XML;
use XML::Query::Statement;

unit class XML::Query;

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

method AT-KEY ($statement)
{
  self.apply($statement.join(' '));
}

method CALL-ME ($statement)
{
  self.apply($statement.join(','));
}

