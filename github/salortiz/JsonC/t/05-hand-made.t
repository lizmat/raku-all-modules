use v6;
use Test;
use JsonC;

plan 21;

ok (my @ja is JSON-P),	'Can declare a JSON-P';
isa-ok @ja, JsonC::JSON-P;

nok @ja.elems,		'Empty';

ok @ja.push('foo'),	'Can push';

ok @ja.elems,		'Pushed';

is @ja[0], 'foo',	'The value';

lives-ok {
    @ja.push: 1, Nil, pi, False;
}, 'Push slurpy';

ok @ja[1] ~~ 1,		'[1] is Int (1)';
ok @ja[2] ~~ Nil,	'[2] is Nil';
ok @ja[3] ~~ Num & pi,	'[3] is Num (pi)';
ok @ja[4] ~~ Bool,	'[4] is Bool';
nok @ja[4],		'btw False';

lives-ok {
    @ja.push: (:hash{:a(e), :b, :c<¯\_(ツ)_/¯>, :!d});
}, 'Push pair';

ok @ja[5] ~~ JsonC::JSON-A, 'Pair is Associative';

is @ja[5]<hash><c>:delete, '¯\_(ツ)_/¯', 'such is life :-)';
ok @ja[5]<hash>.elems == 3, 'Delete works';

lives-ok {
    @ja.push: |<bar baz>;
}, 'Push slip';

lives-ok {
    @ja.push: (5, 6, 7, 8);
}, 'Push list';

is @ja.elems, 9,	'All pushed';

isa-ok @ja[8], JsonC::JSON-P, 'Last was nested';

is @ja.Str(:pretty),
'[
  "foo",
  1,
  null,
  3.1415926535897931,
  false,
  {
    "hash":{
      "a":2.7182818284590455,
      "d":false,
      "b":true
    }
  },
  "bar",
  "baz",
  [
    5,
    6,
    7,
    8
  ]
]', 'Indeed';
