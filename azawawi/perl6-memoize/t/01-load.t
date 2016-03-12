use v6;

use Test;

plan 7;

use Memoize;
ok 1, "'use Memoize' worked!";

{
  sub get-slowed-result(Int $n where $_ >= 0) is memoized {
    sleep $n / 50;
    return 1 if $n <= 1;
    return get-slowed-result($n - 1) * $n;
  }

  say sprintf("get-slowed-result(%d) is %d", $_, get-slowed-result($_)) for 0..10;

  ok 1, "'is memoized' worked!";
}

{
  sub get-slowed-result(Int $n where $_ >= 0) is memoized() {
    sleep $n / 50;
    return 1 if $n <= 1;
    return get-slowed-result($n - 1) * $n;
  }
  say sprintf("get-slowed-result(%d) is %d", $_, get-slowed-result($_)) for 0..10;

  ok 1, "'is memoized()' worked!"
}

{
  sub get-slowed-result(Int $n where $_ >= 0)
    is memoized(:cache_size(5), :cache_strategy("LRU"), :debug)
  {
    sleep $n / 50;
    return 1 if $n <= 1;
    return get-slowed-result($n - 1) * $n;
  }
  say sprintf("get-slowed-result(%d) is %d", $_, get-slowed-result($_)) for 0..10;

  ok 1, "'is memoized(...)' worked!";
}

sub is-pure(&f) {
  my $x = &f.can('IS_PURE').elems >= 1;
  say "x: $x";
  return $x
}

{
  sub memoized-but-impure($n)  is memoized(:pure(False)) { $n }
  sub memoized-and-pure($n)    is memoized               { $n }
  sub memoized-and-is-pure($n) is memoized is pure       { $n }

  ok !is-pure(&memoized-but-impure),   "':pure(False) disables implicit 'is pure'";
  ok is-pure(&memoized-and-pure),    "'is memoized implies 'is pure'";
  ok is-pure(&memoized-and-is-pure), "redundant is pure";
}
