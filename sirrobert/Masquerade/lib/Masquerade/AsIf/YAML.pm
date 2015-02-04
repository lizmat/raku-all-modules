
role AsIf::YAML;

##
# This helper sub renders class-based objects as JSON.  Objects are treated
# as hashes, public properties are rendered; private properties are omitted.
# This could probably be improved to do things like let objects that inherit
# from Arrays render as JavaScript arrays (or something).  But it works fine
# for my purposes for now.
sub asif-yaml ($obj) {
  return _render($obj);
}

# Render as string.
method Str () {
  return asif-yaml(self);
}

# Outsource gist to Str.
method gist () {
  return self.Str();
}

# Do DRY pre-processing of complex structures like hashes and arrays.
sub pre-process (Str $str is rw, Int $depth) {
  $str ~= "\n" if $depth;
  return $str;
}

# Same as above, but for post-processing.
sub post-process (Str $str is rw, Int $depth) {
  return $str;
}

# Let the interpreter figure out which one we mean.  There's a _render
# method for each of the major data types (or if something's missing, we can
# add it upon request).
multi sub _render(%hash, Int $depth = 0) {
  my Str $output;
  pre-process($output, $depth);
  my $strlen = 0;
  for %hash.keys -> $k {
    $strlen = $k.chars if $k.chars > $strlen;
  }

  for %hash.kv -> $k, $v {
    $output ~= '  ' x $depth;
    $output ~= sprintf("%-{$strlen + 1}s ", "$k:") ~ _render($v, $depth+1);
  }
  post-process($output, $depth);
  return $output;
}

multi sub _render (@array, Int $depth = 0) {
  my Str $output;
  pre-process($output, $depth);
  for @array -> $element {
    $output ~= '  ' x $depth ~ '- ' ~ _render($element, $depth + 1);
  }
  post-process($output, $depth);
  return $output;
}

multi sub _render (Pair $pair, Int $depth=0) {
  return _render({$pair.key => $pair.value});
}

multi sub _render (Str $str, Int $depth = 0) {
  my Str $output;
  $output ~= "$str\n";
  return $output;
}

multi sub _render (Numeric $num, Int $depth = 0) {
  my Str $output;
  $output = $num.Str ~ "\n";
  return $output;
}

# This is the one that handles custom classes.  I think there's a better way
# to get here, or some checking that could be done, but it'll do for now.
multi sub _render ($obj, Int $depth = 0) {
  my %as-hash;
  for $obj.^attributes -> $attr {
    %as-hash{$attr.name.substr(2)} = $attr.get_value($obj);
  }
  return _render(%as-hash);
}



