unit module DateTime::Math;

my subset DurationUnits of Str where -> $unit { $unit ~~ /^<[smhdwMy]>$/ }

## to-seconds: takes a value and a unit string, and converts the value
#  into seconds.
#
#  The value must be a number, the unit string must be one of:
#
#   's'  Seconds,  this is redundant it returns the string without the 's'.
#   'm'  Minutes,  so 1m will return 60.
#   'h'  Hour,     so 1h will return 3600.
#   'd'  Day,      so 1d will return 86400.
#   'w'  Week,     so 1w will return 604800.
#   'M'  Month,    so 1M will return 2592000. This is based on 30 days.
#   'y'  Year,     so 1y will return 31449600. Uses a round 365 days.
#
#  The Month estimation is not very accurate as it assumes 30 days regardless
#  of month, if you need more accuracy, use a day count instead.
#
# The Year estimation is based on a round 365 days, and does not take into
# account leap years or anything else. Again, if you need more accuracy, 
# use a smaller unit.
# 
#
sub to-seconds ( Numeric $value, DurationUnits $in ) is export {
  my $minute = $value  *  60;
  my $hour   = $minute *  60;
  my $day    = $hour   *  24;
  my $week   = $day    *   7;
  my $month  = $day    *  30;
  my $year   = $day    * 365; 
  given $in {
    when 's' { return $value }
    when 'm' { return $minute }
    when 'h' { return $hour }
    when 'd' { return $day }
    when 'w' { return $week }
    when 'M' { return $month }
    when 'y' { return $year }
  }
}

## from-seconds: takes a value in seconds and converts it into the
#  specified unit.
#
# The value and unit must be specified using the same rules as to-seconds().
#
sub from-seconds ( Numeric $value, DurationUnits $to ) is export {
  my $minute = $value  /  60;
  my $hour   = $minute /  60;
  my $day    = $hour   /  24;
  my $week   = $day    /   7;
  my $month  = $day    /  30;
  my $year   = $day    / 365; 
  given $to {
    when 's' { return $value }
    when 'm' { return $minute }
    when 'h' { return $hour }
    when 'd' { return $day }
    when 'w' { return $week }
    when 'M' { return $month }
    when 'y' { return $year }
  }
}

## duration-from-to: takes a value, the unit string the value is currently in,
## and the unit string you want to covert the value to. 
sub duration-from-to( Numeric $value, DurationUnits $in, DurationUnits $to) 
  is export
{
  from-seconds(to-seconds($value, $in), $to);
}

multi infix:<+>(DateTime:D $dt, Numeric:D $x) is export {
#  $*ERR.say: "We're in the proper addition routine.";
  DateTime.new(($dt.posix + $x).Int, :timezone($dt.timezone), :formatter($dt.formatter))
}

multi infix:<+>(Numeric:D $x, DateTime:D $dt) is export {
  $dt + $x;
}

multi infix:«-»(DateTime:D $dt, Numeric:D $x) is export {
#  $*ERR.say: "We're in the proper substraction routine.";
  DateTime.new(($dt.posix - $x).Int, :timezone($dt.timezone), :formatter($dt.formatter))
}

multi infix:<->(DateTime:D $a, DateTime:D $b) is export {
  Duration.new($a.posix - $b.posix);
}


# Now included in rakudo
#multi infix:<cmp>(DateTime $a, DateTime $b) is export {
#  $a.posix cmp $b.posix;
#}
#
#multi infix:«<=>»(DateTime $a, DateTime $b) is export {
#  $a.posix <=> $b.posix;
#}
#
#multi infix:<==>(DateTime $a, DateTime $b) is export {
#  $a.posix == $b.posix;
#}
#
#multi infix:<!=>(DateTime $a, DateTime $b) is export {
#  $a.posix != $b.posix;
#}
#
#multi infix:«<=»(DateTime $a, DateTime $b) is export {
#  $a.posix <= $b.posix;
#}
#
#multi infix:«<»(DateTime $a, DateTime $b) is export {
#  $a.posix < $b.posix;
#}
#
#multi infix:«>=»(DateTime $a, DateTime $b) is export {
#  $a.posix >= $b.posix;
#}
#
#multi infix:«>»(DateTime $a, DateTime $b) is export {
#  $a.posix > $b.posix;
#}

