unit module DateTime::TimeZone;

## An app-facing set of friendly subroutines for working with timezones.

sub timezone (Str $name, DateTime $datetime=DateTime.new(time)) is export {
  my $namespace = $name.subst('/', '::', :g);
  $namespace ~~ s:g/\+/_plus_/;
  $namespace ~~ s:g/\-/_minus_/;
  $namespace = "DateTime::TimeZone::Zone::" ~ $namespace;
  my $class;
  try {
    require ::($namespace);
    $class = ::($namespace).new(:$datetime);
    CATCH {
      warn "Could not find a TimeZone class for '$name'.";
    }
  }
  return $class;
}

sub to-timezone (Str $name, DateTime $datetime) is export {
  $datetime.in-timezone(timezone($name, $datetime));
}

sub tz-offset (Str $offset-string) is export {
  if $offset-string ~~ /('+'|'-')? (\d\d) ':'? (\d\d)/ {
    my $sign = $0 ?? ~$0 !! '+';
    my $hour = +$1;
    my $min  = +$2;
    my $offset = $hour * 60 * 60;
    $offset += $min * 60;
    if $sign eq '-' {
      $offset *= -1;
    }
    $offset;
  }
  else {
    warn "invalid offset string";
    0;
  }
}

