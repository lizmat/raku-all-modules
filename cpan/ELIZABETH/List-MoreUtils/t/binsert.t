use v6.c;

use List::MoreUtils <binsert bsearch_insert>;
use Test;

plan 9;

ok &binsert =:= &bsearch_insert, 'is bsearch_insert the same as binsert';

{
    my @list;
    is 0, binsert( { $_ cmp "Hello" }, "Hello", @list),
      "Inserting into empty list";
    is 1, binsert( { $_ cmp "world" }, "world", @list),
      "Inserting into one-item list";
}

my @even = map { $_ * 2 }, 1 .. 100;
my @odd  = map { $_ * 2 - 1 }, 1 .. 100;
my @expected = 1..200;
my @in;

@in = @even;
for @odd -> $v {
    binsert { $_ <=> $v }, $v, @in;
}
is-deeply @in, @expected,
  "binsert odd elements into even list succeeded";

@in = @even;
for @odd.reverse -> $v {
    binsert { $_ <=> $v }, $v, @in;
}
is-deeply @in, @expected,
  "binsert odd elements reversely into even list succeeded";

@in = @odd;
for @even -> $v {
    binsert { $_ <=> $v }, $v, @in;
}
is-deeply @in, @expected,
  "binsert even elements into odd list succeeded";

@in = @odd;
for @even.reverse -> $v {
    binsert { $_ <=> $v }, $v, @in;
}
is-deeply @in, @expected,
  "binsert even elements reversely into odd list succeeded";

@in = @even;
@expected = @in.map: { |($_, $_) };
for @even -> $v {
    binsert { $_ <=> $v }, $v, @in;
}
is-deeply @in, @expected,
  "binsert existing even elements into even list succeeded";

@in = @even;
@expected = @in.map: { |($_, $_) };
for @even.reverse -> $v {
    binsert { $_ <=> $v }, $v, @in;
}
is-deeply @in, @expected,
  "binsert existing even elements reversely into even list succeeded";

# vim: ft=perl6 expandtab sw=4
