use lib 't/lib';
use Test;
use Digest::FNV;
use Digest::FNV :DEPRECATED;
use cases;

my @test-vals = test-vals;
my @expected  = test-expected;
plan @expected.elems;

my ($tstr, $ccnt, $fnv032, $fnv064, $fnv132, $fnv1a32, $fnv164, $fnv1a64);
for 0..@test-vals.elems {
  $fnv032  = fnv0(@test-vals[$_], bits => 32);
  $fnv064  = fnv0(@test-vals[$_]);
  $fnv132  = fnv1(@test-vals[$_], bits => 32);
  $fnv164  = fnv1(@test-vals[$_]);
  $fnv1a32 = fnv1a(@test-vals[$_], bits => 32);
  $fnv1a64 = fnv1a(@test-vals[$_]);
  $tstr    = @test-vals[$_].perl;
  $ccnt    = try { $tstr.chars } // 0;
  $tstr .=substr(0..10)
    if $ccnt > 10;
  is $fnv032, @expected[$_],
    "fnv0-32({$tstr.perl}{$ccnt > 10 ?? '..' !! ''})";
  is $fnv132, @expected[$_ + 204],
    "fnv1-32({$tstr.perl}{$ccnt > 10 ?? '..' !! ''})";
  is $fnv1a32, @expected[$_ + 408],
    "fnv1a-32({$tstr.perl}{$ccnt > 10 ?? '..' !! ''})";
  is $fnv064, @expected[$_ + 612],
    "fnv0-64({$tstr.perl}{$ccnt > 10 ?? '..' !! ''})";
  is $fnv164, @expected[$_ + 816],
    "fnv1-64({$tstr.perl}{$ccnt > 10 ?? '..' !! ''})";
  is $fnv1a64, @expected[$_ + 1020],
    "fnv1a-64({$tstr.perl}{$ccnt > 10 ?? '..' !! ''})";
}

# vi:syntax=perl6
