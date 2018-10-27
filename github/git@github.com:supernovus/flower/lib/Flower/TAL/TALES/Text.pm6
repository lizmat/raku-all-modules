unit class Flower::TAL::TALES::Text;

has $.flower is rw;
has $.tales  is rw;

has %.handlers =
  'uppercase'  => 'text_uc',
  'upper'      => 'text_uc',
  'uc'         => 'text_uc',
  'lowercase'  => 'text_lc',
  'lower'      => 'text_lc',
  'lc'         => 'text_lc',
  'ucfirst'    => 'text_ucfirst',
  'uc_first'   => 'text_ucfirst',
  'substr'     => 'text_substr',
  'printf'     => 'text_printf',
  'sprintf'    => 'text_printf';

## Usage:  uc: varname
method text_uc ($query, *%opts) {
  my $result = $.tales.query($query);
  return $.tales.process-query($result.uc, |%opts);
}

## Usage:  lc: varname
method text_lc ($query, *%opts) {
  my $result = $.tales.query($query);
  return $.tales.process-query($result.lc, |%opts);
}

## Usage:  ucfirst: varname
method text_ucfirst ($query, *%opts) {
  my $result = $.tales.query($query);
  return $.tales.process-query($result.tc, |%opts);
}

## Usage:  substr: opts string/variable
## Opts: 1[,2][,3]  
##  where 1 is the offset to start at,
##  2 is the number of characters to keep,
##  and if 3 is true add an ellipsis (...) to the end.
## E.g.: <div tal:content="substr: 3,5 'theendoftheworld'"/>
## Returns: <div>endof</div>
method text_substr ($query, *%opts) {
  my ($subquery, $start, $chars, $ellipsis) = 
    $.tales.get-args($query, 0, Nil, Nil);
  my $text = $.tales.query($subquery);
  if defined $text {
    my $substr = $text.substr($start, $chars);
    if $ellipsis {
      $substr ~= '...';
    }
    return $.tales.process-query($substr, |%opts);
  }
}

## Usage:  printf: format varname/path
## E.g.: <div tal:content="printf: '$%0.2f' '2.5'"/>
## Returns: <div>$2.50</div>
method text_printf ($query, *%opts) {
  my ($format, $text) = $.tales.get-args(:query, $query, Nil);
  if defined $text && defined $format {
    my $formatted = sprintf($format, $text);
    return $.tales.process-query($formatted, |%opts);
  }
}

