class Flower::TAL::TALES::Default; 

has $.flower;
has $.tales;

has %.handlers =
  'str'    => 'parse_string',
  'string' => 'parse_string',
  'is'     => 'parse_true',
  'true'   => 'parse_true',
  'false'  => 'parse_false',
  'not'    => 'parse_false';

method parse_true ($query, *%opts) {
  my $result = $.tales.query($query, :bool);
  return ?$result;
}

method parse_false ($query, *%opts) {
  my $result = $.tales.query($query, :bool);
  if $result { return False; }
  else { return True; }
}

method parse_string ($query, *%opts) {
  my $string = $.tales.parse-string($query);
  return $.tales.process-query($string, |%opts);
}

