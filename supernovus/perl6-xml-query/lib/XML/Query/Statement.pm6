use XML::Query::Results;

unit class XML::Query::Statement;

has $.statement;   ## The statement we represent.
has $.parent;      ## The top-level XML::Query object.

method apply ($xml)
{
  my @results;

  my $cattr = $.parent.class-attr;

  my @groups = $!statement.split(/','\s*/);
  for @groups -> $group
  {
    my @tree = $group.split(/\s+/);
    my $pos = $xml; ## We start from the root.
    my $expand = False;
    my $recurse = 999;
    for @tree -> $branch
    {
      if $branch eq '>' { $recurse = 0; next; }
      if $branch ~~ /^'#' (<ident>)/
      {
        my $id = ~$0;
        $pos .= getElementById($id);
        if ! $pos.defined { last; }
        $expand = False;
      }
      elsif $branch ~~ /^'.' (<ident>)/
      {
        my $class = ~$0;
        my %query =
        %(
          RECURSE => $recurse,
          OBJECT  => True,
          $cattr  => $class,
        );
        $pos .= elements(|%query);
        if ! $pos.defined { last; }
        $expand = True;
      }
      elsif $branch ~~ /^(<ident>)/
      {
        my $tag = ~$0;
        $pos .= getElementsByTagName($tag, :object);
        if ! $pos.defined { last; }
        $expand = True;
      }
      if $branch ~~ /'[' (<ident>) '=' '"'? (.*?) '"'? ']'/
      {
        my $key = ~$0;
        my $val = ~$1;
        my %query =
        %(
          RECURSE => $recurse,
          OBJECT  => True,
          $key    => $val,
        );
        $pos .= elements(|%query);
        if ! $pos.defined { last; }
        $expand = True;
      }
      $recurse = 999;
    }
    if ! $pos.defined { next; }
    if $expand
    {
      @results.push: $pos.nodes;
    }
    else
    {
      @results.push: $pos;
    }
  }
  return XML::Query::Results.new(:@results, :parent(self));
}

