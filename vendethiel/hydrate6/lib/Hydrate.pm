unit module Hydrate;

my @language-types =
  # NOTE: these CAN NOT be strings, because A::B::Int.^name is just Int
  Int, int,
  Str, str,
  Bool,
  Mu, Any, Cool,
  Pair,
;

# TODO: note: we don't actually type check anything ourselves
#       maybe that'll yield bad error messages?
sub value-for(Mu:U \type, Str $sigil, \value,
    Bool :$error-on-extra = True) {
  given $sigil {
    when '$' {
      # Here, we need to work a bit around the language, as any() won't work
      #  due to Mu being in the list.
      if @language-types.grep(-> \t { t.WHAT =:= type }).elems {
        value;
      } else {
        hydrate(type, value, :$error-on-extra);
      }
    }
    when '@' {
      die "Type mismatch: attribute was not Positional" unless value ~~ Positional;
      # then, use type.of, to get the array/list's type
      value.map(-> \e, { value-for(type.of, '$', e, :$error-on-extra); });
    }
    default { die "Internal error: unsupported sigil $sigil"; }
  }
}


sub hydrate(Mu:U \T, %data is copy,
    Bool :$error-on-extra = True)
    is export {
  my %made;
  for T.^attributes -> $attr {
    next unless $attr.has_accessor;
    my $name = $attr.name.substr(2); # remove @!, $!, etc
    with %data{$name}:delete -> \value {
      %made{$name} = value-for($attr.type, $attr.name.comb[0], value,
        :$error-on-extra);
    } else {
      die "Missing attribute $name for {T.^name}" if $attr.required;
      next; # otherwise, quietly skip the attribute
    }
  }
  if %data && $error-on-extra {
    # die, but don't print the name (would let users inject text)
    die "Extra attributes while building {T.^name}"
  }
  T.new(|%made);
}
