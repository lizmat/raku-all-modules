unit module Geo::Ellipsoid::GenFuncs;

sub to_decimal($deg is copy, $min, $sec) is export {
  # may have leading [nNeEsSwW]
  if $deg ~~ m/^ (<[nNeEsSwW]>**1..1) (.*) $/ {
    my $pref = $0;
    $deg = $1;
  }
  if $min {
    $deg += $min / 60;
  }
  if $sec {
    $deg += $sec / 3600;
  }
  return $deg;
}

sub to_hms($Deg, $typ) is export {
  # separate into int and decimal parts
  my $deg  = $Deg.Int;
  my $frac = $Deg - $deg;
  my $Min  = $frac * 60;
  my $min  = $Min.Int;
  $frac    = $Min - $min;
  my $sec  = $frac * 60;

  my $pref = $deg >= 0 ?? 'N' !! 'S';
  if ($typ ~~ m:i/lon/) {
    $pref = $deg >= 0 ?? 'E' !! 'W';
  }
  return "$pref $deg $min $sec";
}
