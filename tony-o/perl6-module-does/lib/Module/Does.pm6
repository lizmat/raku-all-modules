
sub findglob($type, @start = GLOBAL::.values.Slip){
  my @found;
  for @start -> $t {
    try @found.append: |@(findglob($type, $t.WHO.values.Slip));
    try @found.append: $t if $t ~~ ::($type);
  }
  return @found;
}

role Module::Does[*@types] {
  has %!base-types;
  submethod BUILD(*%_){
    for @types {
      $_ = $_.^name unless $_ ~~ Pair || $_ ~~ Str;
      given $_ {
        when * ~~ Pair {
          %!base-types{$_.key} = findglob($_.key);
          %!base-types{$_.key} = findglob($_.value) unless
            %!base-types{$_.key}.elems > 0;
        }
        when Str {
          %!base-types{$_} = findglob($_);
        }
        default {
          die "Unknown type passed $_";
        }
      }
    }
    callsame;
  }
}
