use XML;

unit class XML::Query::Results;

has @.results;        ## The matching elements.
has $.parent;         ## The Statement that generated these results.

method element
{
  @!results[0];
}

method elem
{
  warn ".elem is deprecated, please use .element instead";
  self.element;
}

method elements
{
  @!results;
}

method elems
{
  warn ".elems is deprecated, please use .elements instead";
  self.elements;
}

method !spawn (*@results)
{
  self.new(:$.parent, :@results);
}

method first
{
  self!spawn(@!results[0]);
}

method last
{
  self!spawn(@!results[@!results.end]);
}

method AT-POS ($offset) 
{
  self!spawn(@!results[$offset]);
}

method results-xml
{
  my $xml = XML::Element.craft('results');
  $xml.nodes = @!results;
  return $xml;
}

method find ($statement)
{
  $.parent.parent.compile(~$statement).apply(self.results-xml);
}

