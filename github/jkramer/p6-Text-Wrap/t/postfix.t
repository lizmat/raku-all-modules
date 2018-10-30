
use Test;

use lib 'lib';

use Text::Wrap;

plan 2;

is(
  wrap-text("foo bar baz quux test 123", :width(10)),
  "foo bar\nbaz quux\ntest 123",
  'no postfix'
);

is(
  wrap-text("foo bar baz quux test 123", :width(10), :postfix('⤶')),
  "foo bar⤶\nbaz quux⤶\ntest 123",
  'Postfix ⤶'
);

done-testing;
