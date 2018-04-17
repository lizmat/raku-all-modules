use v6.c;

use List::MoreUtils <arrayify>;
use Test;

plan 4;

{
    my @in = 1 .. 4, [5 .. 7], 8 .. 11, [[12 .. 17]], 18;
    my @out = arrayify @in;
    is-deeply @out, [1 .. 18], "linear flattened int mix i";
}

{
    my @in = 1 .. 4, [[5 .. 11]], 12, [[13 .. 17]];
    my @out = arrayify @in;
    is-deeply @out, [1 .. 17], "linear flattened int mix ii";
}

{
    # typical structure when parsing XML using XML::Hash::XS
    my %src =
      root => {
        foo_list => {foo_elem => {attr => 42}},
        bar_list => {bar_elem => [{hummel => 2}, {hummel => 3}, {hummel => 5}]}
      }
    ;
    my @foo_elems = arrayify %src<root><foo_list><foo_elem>;
    is-deeply @foo_elems, [{attr => 42},],
      "arrayified struct with one element";
    my @bar_elems = arrayify %src<root><bar_list><bar_elem>;
    is-deeply @bar_elems, [{hummel => 2}, {hummel => 3}, {hummel => 5}],
      "arrayified struct with three elements";
}

# vim: ft=perl6 expandtab sw=4
