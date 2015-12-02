use v6;
use Math::Random;

unit class Math::Random::JavaStyle does Math::Random;

has Int $!tane;

submethod new(Int $seed) {
  my $r = Math::Random::JavaStyle.new;
  $r.setSeed($seed);
  return $r;
}

method setSeed(Int $seed) {
  $!tane = ($seed +^ 0x5DEECE66D) +& ((1 +< 48) - 1);
  $.haveNextGaussian = False;
}

method nxt(Int $bits) returns Int {
  die "\$bits must be at least 1" if $bits < 1;
  if $bits > 32 {
    return self.nxt(32) + (self.nxt($bits - 32) +< 32);
  }
  $!tane = ($!tane * 0x5DEECE66D + 0xB) +& ((1 +< 48) - 1);
  return (($!tane + (1 +< 64)) +> (48 - $bits)) +& 0xFFFFFFFF;
}
