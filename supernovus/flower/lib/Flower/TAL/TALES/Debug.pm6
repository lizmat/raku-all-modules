class Flower::TAL::TALES::Debug;

has $.flower is rw;
has $.tales  is rw;

has %.handlers = 
  'dump' => 'debug_dump',
  'what' => 'debug_what';

method debug_dump($query, *%opts) {
  my $result = $.tales.query($query, :noescape);
  %opts<noescape>:delete;
  return $.tales.process-query($result.perl, :noescape, |%opts);
}

method debug_what($query, *%opts) {
  my $result = $.tales.query($query, :noescape);
  %opts<noescape>:delete;
  return $.tales.process-query($result.WHAT.perl, :noescape, |%opts);
}

