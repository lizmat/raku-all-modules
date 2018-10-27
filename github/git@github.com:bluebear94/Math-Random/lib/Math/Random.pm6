use v6;

unit role Math::Random;

method setSeed(Int $seed) { ... }

method nxt(Int $bits) returns Int { ... }

multi method nextInt returns Int {
  return self.nxt(32);
}

multi method nextInt(Int $bound) returns Int {
  die "$bound must be positive" if $bound <= 0;
  if ($bound +& -$bound) == $bound { # if bound is a power of 2
    return (($bound * self.nxt(31)) +> 31) +& 0xFFFFFFFF;
  }
  my Int $bits;
  my Int $val;
  repeat {
    $bits = self.nxt(31);
    $val = $bits % $bound;
  } while $bits - $val + $bound - 1 < 0;
  return $val;
}

multi method nextLong returns Int {
  return self.nxt(64);
}

multi method nextLong(Int $bound) returns Int {
  die "$bound must be positive" if $bound <= 0;
  if ($bound +& -$bound) == $bound { # if bound is a power of 2
    return (($bound * self.nxt(63)) +> 63) +& 0xFFFF_FFFF_FFFF_FFFF;
  }
  my Int $bits;
  my Int $val;
  repeat {
    $bits = self.nxt(63);
    $val = $bits % $bound;
  } while $bits - $val + $bound - 1 < 0;
  return $val;
}

method nextBoolean returns Bool {
  return self.nxt(1) != 0;
}

multi method nextDouble returns Num {
  return self.nxt(53);
}

multi method nextDouble(Num $max) returns Num {
  return $max * self.nextDouble;
}

has Num $!nextNextGaussian;
has Bool $.haveNextGaussian is rw = False;

method nextGaussian returns Num {
  if ($.haveNextGaussian) {
    $.haveNextGaussian = False;
    return $.nextNextGaussian;
  } else {
    my Num $v1;
    my Num $v2;
    my Num $s;
    repeat {
      $v1 = 2 * self.nextDouble - 1;
      $v2 = 2 * self.nextDouble - 1;
      $s = $v1 * $v1 + $v2 * $v2;
    } while ($s >= 1 || $s == 0);
    my Num $multiplier = sqrt(-2 * log($s) / $s);
    $!nextNextGaussian = $v2 * $multiplier;
    $.haveNextGaussian = True;
    return $v1 * $multiplier;
  }
}
