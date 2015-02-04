# JSON::Tiny is used to render basic stuff like hashes.
use JSON::Tiny;

role AsIf::Perl;

# Tries to interpret the thing you're doing as a JSON object string.
# Obviously this won't work if it's not one, so don't do that.
multi method postcircumfix:<{ }> (Str $str) {
  my %hash = from-json(self);
  return %hash{$str};
}

# Tries to interpret the thing you're doing as a JSON array string.
# Obviously this won't work if it's not a JSON string, so don't do that.
multi method postcircumfix:<[ ]> (Int $num) {
  my $array = from-json(self);
  return $array[$num];
}


