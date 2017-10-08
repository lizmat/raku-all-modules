use v6;
use Math::Random;

unit class Math::Random::MT does Math::Random;

has Int $.w;
has Int $.n;
has Int $.m;
has Int $.r;
has Int $.a;
has Int $.b;
has Int $.c;
has Int $.s;
has Int $.t;
has Int $.u;
has Int $.d;
has Int $.l;
has Int $.f;
has Int @!state;
has Int $!index = $!n + 1;
has Int $!lowerMask = (1 +< $!r) - 1;
has Int $!upperMask = (+^$!lowerMask) +& ((1 +< $!w) - 1);

submethod mt19937 {
  Math::Random::MT.new(
    w => 32,
    n => 624,
    m => 397,
    r => 31,
    a => 0x9908B0DF,
    u => 11,
    d => 0xFFFFFFFF,
    s => 7,
    b => 0x9D2C5680,
    t => 15,
    c => 0xEFC60000,
    l => 18,
    f => 1812433253
  );
}

submethod mt19937_64 {
  Math::Random::MT.new(
    w => 64,
    n => 312,
    m => 156,
    r => 31,
    a => 0xB5026F5AA96619E9,
    u => 29,
    d => 0x5555555555555555,
    s => 17,
    b => 0x71D67FFFEDA60000,
    t => 37,
    c => 0xFFF7EEE000000000,
    l => 43,
    f => 6364136223846793005
  );
}

method setSeed(Int $seed) {
  $!index = $!n;
  @!state[0] = $seed +& ((1 +< $!w) - 1);
  loop (my int $i = 1; $i < $!n; $i = $i + 1) {
    my $prev = @!state[$i - 1];
    @!state[$i] = ($!f * ($prev +^ ($prev +> ($!w - 2))) + $i) +&
      ((1 +< $!w) - 1);
  }
}

submethod extract {
  die "SEED THE FROOPING GENERATOR!" if $!index > $!n;
  self.twist if $!index == $!n;
  my $y = @!state[$!index];
  $y = $y +^ (($y +> $!u) +& $!d);
  $y = $y +^ (($y +< $!s) +& $!b);
  $y = $y +^ (($y +< $!t) +& $!c);
  $y = $y +^ ($y +> $!l);
  $!index++;
  return $y +& ((1 +< $!w) - 1);
}

submethod twist {
  loop (my int $i = 0; $i < $!n; $i = $i + 1) {
    my $x =
      (@!state[$i] +& $!upperMask) +
      (@!state[($i + 1) % $!n] +& $!lowerMask);
    my $xA = $x +> 1;
    $xA = $xA +^ $!a if $x +& 1;
    @!state[$i] = @!state[($i + $!m) % $!n] +^ $xA;
  }
  $!index = 0;
}

method nxt(Int $bits) returns Int {
  die "\$bits must be at least 1" if $bits < 1;
  if $bits > $!w {
    return self.nxt($!w) + (self.nxt($bits - $!w) +< $!w);
  }
  return (self.extract +> ($!w - $bits)) +& ((1 +< $!w) - 1);
}
