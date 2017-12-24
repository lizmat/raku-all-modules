use Test;
use Algorithm::BitMap;

plan 5;

{
  lives-ok { my $bitmap = BitMap.new };
  lives-ok { my $bitmap = BitMap.new(n => 16) };
  lives-ok { my $bitmap = BitMap.new(n => 10000000) };
  lives-ok { my $bitmap = BitMap.new(bits => 31) };
  lives-ok { my $bitmap = BitMap.new(bits => 2**1000-1) };
}
