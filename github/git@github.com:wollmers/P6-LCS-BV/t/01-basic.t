use v6;
use Test;
use LCS::BV;
use LCS::All;

# say so $[[2,3],[2,4],] eqv $[[[0,1],[2,3],],[[0,1],[2,4],]].any;
my sub any_of ($result, $expected) {
  return so $result eqv $expected.any;
}

my $examples = [
  [ '',
    '' ],
  [ 'a',
    '' ],
  [ '',
    'a' ],
  ['ttatc__cg',
   '__agcaact'],
  ['abcabba_',
   'cb_ab_ac'],
  ['yqabc_',
    'zq__cb'],
  [ 'rrp',
    'rep'],
  [ 'a',
    'b' ],
  [ 'aa',
    'a_' ],
  [ 'abb',
    '_b_' ],
  [ 'a_',
    'aa' ],
  [ '_b_',
    'abb' ],
  [ 'ab',
    'cd' ],
  [ 'ab',
    '_b' ],
  [ 'ab_',
    '_bc' ],
  [ 'abcdef',
    '_bc___' ],
  [ 'abcdef',
    '_bcg__' ],
  [ 'xabcdef',
    'y_bc___' ],
  [ 'öabcdef',
    'ü§bc___' ],
  [ 'o__horens',
    'ontho__no'],
  [ 'Jo__horensis',
    'Jontho__nota'],
  [ 'horen',
    'ho__n'],
  [ 'Chrerrplzon',
    'Choereph_on'],
  [ 'Chrerr',
    'Choere'],
  [ 'rr',
    're'],
  [ 'abcdefg_',
    '_bcdefgh'],
  [ 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVY_',
    '_bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVYZ'],
# TODO
  [ 'abcdefghijklmnopqrstuvwxyz01234567890123456789ABCDEFGHIJKLMNOPQRSTUVY_',
    '_bcdefghijklmnopqrstuvwxyz01234567890123456789ABCDEFGHIJKLMNOPQRSTUVYZ'],
];

plan *;

if (0) {
nok(any_of($[[0,1],], $[[],]), 'any_of($[[0,1],], $[[],]) is false');
nok(any_of($[], $[[[0,1],],]), 'any_of($[], $[[[0,1],],]) is false');
nok(any_of($[[0,1],], $[[[0,2],],]), 'any_of($[[0,1],], $[[[0,2],],]) is false');

ok(any_of($[], $[[],]), 'any_of($[], $[[],]) is true');
ok(any_of($[[0,1],], $[[[0,1],],]), 'any_of($[[0,1],], $[[[0,1],],]) is true');
ok(any_of($[[0,1],[2,4],], $[[[0,1],[2,3],],[[0,1],[2,4],]]),
  'any_of($[[0,1],[2,4],], $[[[0,1],[2,3],],[[0,1],[2,4],]]) is true');
ok(any_of($[[0,1],[2,3],], $[[[0,1],[2,3],],[[0,1],[2,4],]]),
  'any_of($[[0,1],[2,3],], $[[[0,1],[2,3],],[[0,1],[2,4],]]) is true');
}


if (1) {
for  (@$examples) -> $example {
#for ($examples[27]) -> $example {
  my $a = $example[0];
  my $b = $example[1];
  my $A = [$a.comb(/<-[_]>/)];
  my $B = [$b.comb(/<-[_]>/)];

  if (0) {
  say '$A: ', $A;
  say '$B: ', $B;
  say 'LCS: ', LCS::BV::LCS($A, $B);
  say 'allLCS: ', LCS::All::allLCS($A, $B);
  }

  if (1) {
  ok(
    any_of(
      LCS::BV::LCS($A, $B),
      LCS::All::allLCS($A, $B),
    ),
    "'$a', '$b'",
  );
  }

}
}


done-testing;
