use v6.c;

use List::Util <pairgrep pairfirst pairmap pairs unpairs pairkeys pairvalues>;

use Test;

plan 26;

ok defined(&pairgrep),   'pairgrep defined';
ok defined(&pairfirst),  'pairfirst defined';
ok defined(&pairmap),    'pairmap defined';
ok defined(&pairs),      'pairs defined';
ok defined(&unpairs),    'unpairs defined';
ok defined(&pairkeys),   'pairkeys defined';
ok defined(&pairvalues), 'pairvalues defined';

is-deeply
  pairgrep( -> $a, $b { $b % 2 }, <one 1 two 2 three 3>),
  <one 1 three 3>,
  'pairgrep list';

is-deeply
  pairgrep( -> $a, $b { $a }, (0,"zero",1,"one",2)),
  (1,"one",2,Nil),
  'pairgrep pads with undef';

{
    my @kvlist = "one",1,"two",2;
    pairgrep -> \a, \b { b++ }, @kvlist;
    is-deeply @kvlist, ["one",2,"two",3], 'pairgrep aliases elements';
}

is-deeply
  pairfirst( -> $a, $b { $a.chars == 5 }, <one 1 two 2 three 3>),
  <three 3>,
  'pairfirst list';

is-deeply
  pairfirst( -> $a, $b { $a.chars == 4 }, <one 1 two 2 three 3>),
  (),
  'pairfirst list empty';

is-deeply
  pairmap( -> $a, $b { $a.uc, $b }, <one 1 two 2 three 3>),
  <ONE 1 TWO 2 THREE 3>,
  'pairmap list';

is-deeply
  pairmap( -> $a, $b { $a, |$b }, "one",(1,1,1),"two",(2,2,2),"three",(3,3,3) ),
  ("one",1,1,1, "two",2,2,2, "three",3,3,3),
  'pairmap list returning >2 items';

is-deeply
  pairmap( -> \a, \b { b }, "one",1,"two",2,"three" ),
  (1, 2, Nil),
  'pairmap pads with Nil';

{
    my @kvlist = "one",1,"two",2;
    pairmap -> \a, \b { b++ }, @kvlist;
    is-deeply @kvlist, ["one",2,"two",3], 'pairmap aliases elements';
}

is-deeply
  pairs( "one",1,"two",2,"three",3 ),
  ( P5Pair.new("one",1), P5Pair.new("two",2), P5Pair.new("three",3) ),
  'pairs';

is-deeply
  pairs( "one",1,"two" ),
  ( P5Pair.new("one",1), P5Pair.new("two",Nil) ),
  'pairs pads with Nil';

{
    my @p = pairs "one",1, "two",2;
    is @p[0].key,   "one", 'pairs .key';
    is @p[0].value, 1,     'pairs .value';
}

is-deeply
  unpairs( $("four",4), $("five",5), $("six",6) ),
  ("four",4, "five",5, "six",6),
  'unpairs';

is-deeply
  unpairs( $("four",4), $("five",) ),
  ("four",4, "five",Nil),
  'unpairs with short item fills in Nil';

is-deeply
  unpairs( $("four",4), $("five",5,5) ),
  ("four",4, "five",5),
  'unpairs with long item truncates';

is-deeply pairkeys( <one 1 two 2> ), <one two>, 'pairkeys';

is-deeply pairvalues( <one 1 two 2> ), <1 2>, 'pairvalues';

# pairmap within pairmap
{
    my @kvlist = "o1", <iA A iB B>, "o2", <iC C iD D>;

    is-deeply
      pairmap( -> $a, $b { pairmap -> $a, $b { $b }, @$b }, @kvlist),
      <A B C D>,
      'pairmap within pairmap';
}

# vim: ft=perl6 expandtab sw=4
