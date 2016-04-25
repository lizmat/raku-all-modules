unit class Rabble::Lexicon does Associative;

has Map %!entries;
has $!context;

submethod BUILD(:$!context, :@modules) {
  for @modules -> \wordmod {
    self.import-words-from($!context, wordmod)
  }
}

method AT-KEY($name) { %!entries{$name} }
method elems { %!entries.elems }

multi method define(:$name, :&block) {
  %!entries{$name} = {
    name      => $name,
    block     => &block,
    immediate => False,
    quotation => False
  }
}

multi method define(:$name, :&block, :$immediate) {
  %!entries{$name} = {
    name      => $name,
    block     => &block,
    immediate => True,
    quotation => False
  }
}

method alias($name, $old-name) {
  die "No such word «$old-name»" without self{$old-name};
  my %entry = self{$old-name};
  my %new-entry = %entry.clone :$name;
  %!entries{$name} = %new-entry;
}

method import-words-from($ctx, \wordmod) {
  my \exports = ::wordmod::('EXPORT::DEFAULT');
  for exports::.kv -> $name, &sub {
    self.define:
      name  => $name.substr(1),
      block => &sub.assuming($ctx);
  }
}
