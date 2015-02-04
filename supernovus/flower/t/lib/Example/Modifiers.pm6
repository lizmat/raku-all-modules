class Example::Modifiers;

has $.flower;
has $.tales;

has %.handlers =
  'woah'   => 'woahize';

method woahize ($query, *%opts) {
  my $result = $.tales.query($query);
  my $woah = "Woah, $result, that's awesome!";
  return $.tales.process-query($woah, |%opts);
}

