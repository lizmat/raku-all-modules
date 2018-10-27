use lib 'lib';
use Test;
use Pythonic::Str;

plan 18;
is-deeply 'foobar'[3],      'b',      '.[3]';
is-deeply 'foobar'[3..5],   'bar',    '.[3..5]';
is-deeply 'foobar'[3..*],   'bar',    '.[3..*]';
is-deeply 'foobar'[^(*-3)], 'foo',    '.[^*-3]';
is-deeply 'foobar'[*],      'foobar', '.[*]';
try EVAL "foo"[];
ok (not $! or $! !~~ X::Seq::Consumed), '.[] does not say Seq is consumed';
is-deeply 'foobar'[],     'foobar', '.[]';

is-deeply 'ab'[*]:p,  (0 => 'a', 1 => 'b'), '.[*]:p';
is-deeply 'ab'[*]:k,  (0, 1),               '.[*]:k';
is-deeply 'ab'[*]:kv, (0, 'a', 1, 'b'),     '.[*]:kv';
is-deeply 'ab'[*]:v,  'ab',                 '.[*]:v';

is-deeply 'ab'[*]:exists,  (True, True),    '.[*]:exists';
is-deeply 'ab'[1]:exists,  True,            '.[1]:exists';
throws-like { ('ab'[*]:delete)[0] },  Exception, '(.[*]:delete)[0]';
throws-like { 'ab'[1]:delete      },  Exception, '.[1]:delete';

is-deeply 'foobar'[(3, (4, (5,)))],   'bar',    '.[(3, (4, (5,)))]';

is-deeply 'fo'[-1,1].map(*.^name), <Failure Str>,
  'lists with intermixed Failures are propagated';

todo 'https://rt.perl.org/Ticket/Display.html?id=131280';
# TODO: also write more tests for all the other adverbs when that bug is fixed
is-deeply 'foobar'[(3, (4, (5,)))]:exists, (True, (True, (True,))),
  '.[(3, (4, (5,)))]:exists';
