use Flow::Plugins::TAP;

use Test;

plan 5;

{
  my Flow::Plugins::TAP $parser .=new;
  $parser.parse(q<1..2
ok 5 -
not ok 6 - 
>);
  ok $parser.planned == 2 && $parser.passed == 1 && $parser.failed == 1, '1 ok 1 fail 2 plan';
}

{
  my Flow::Plugins::TAP $parser .=new;
  $parser.parse(q<ok 5 -
not ok 6 -
1..2>);
  ok $parser.planned == -2 && $parser.passed == 1 && $parser.failed == 1, '1 ok 1 fail 2 plan [bottom]';
}

{
  my Flow::Plugins::TAP $parser .=new;
  $parser.parse(q<ok 5 -
not ok 6 -
not ok 3
1..2>);
  ok $parser.planned == -2 && $parser.passed == 1 && $parser.failed == 2 && $parser.problems.elems == 2, '1 ok 3 fail 3 plan [bottom], tests out of sequence';
}

{
  my Flow::Plugins::TAP $parser .=new;
  $parser.parse(q<1..3
ok 5 -
not ok 6 -
not ok 3
not ok 4>);
  ok $parser.planned == 3 && $parser.passed == 1 && $parser.failed == 3 && $parser.problems.elems == 3, '1 ok 3 fail 3 plan, tests out of sequence, too many tests ran';
}

{
  my Flow::Plugins::TAP $parser .=new;
  $parser.parse(q<1..1
not ok 1 - not okay but todo # TODO 'mountain mama'>);
  ok $parser.planned == 1 && $parser.passed == 1 && $parser.failed == 0 && $parser.problems.elems == 0, '1 plan, 1 not-ok but #TODO\'d';
}
