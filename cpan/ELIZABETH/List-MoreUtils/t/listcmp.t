use v6.c;

use List::MoreUtils <listcmp>;
use Test;

plan 2;

{
    my @a = <one two three four five six seven eight nine ten eleven twelve thirteen>;
    my @b = <two three five seven eleven thirteen seventeen>;
    my @c = <one one two three five eight thirteen twentyone>;

    my %expected =
      one       => [0, 2],
      two       => [0, 1, 2],
      three     => [0, 1, 2],
      four      => [0],
      five      => [0, 1, 2],
      six       => [0],
      seven     => [0, 1],
      eight     => [0, 2],
      nine      => [0],
      ten       => [0],
      eleven    => [0, 1],
      twelve    => [0],
      thirteen  => [0, 1, 2],
      seventeen => [1],
      twentyone => [2],
    ;

    is-deeply listcmp(@a, @b, @c), %expected,
      "Sequence vs. Prime vs. Fibonacci sorted out correctly";
}

{
    my @a = <one two three four five six seven eight nine ten eleven twelve thirteen>;
    my @b = Nil,"two","three",Nil,"five",Nil,"seven",Nil,Nil,Nil,"eleven",Nil,"thirteen";

    my %expected =
      one      => [0],
      two      => [0, 1],
      three    => [0, 1],
      four     => [0],
      five     => [0, 1],
      six      => [0],
      seven    => [0, 1],
      eight    => [0],
      nine     => [0],
      ten      => [0],
      eleven   => [0, 1],
      twelve   => [0],
      thirteen => [0, 1],
    ;

    is-deeply listcmp(@a,@b), %expected,
      "Sequence vs. Prime filled with undef sorted out correctly";
}

# vim: ft=perl6 expandtab sw=4
