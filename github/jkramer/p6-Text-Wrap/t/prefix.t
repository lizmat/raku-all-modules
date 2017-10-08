
use Test;

use lib 'lib';

use Text::Wrap;

plan 2;

is(
  wrap-text("foo bar baz quux test 123", :width(10)),
  "foo bar\nbaz quux\ntest 123",
  'no prefix'
);

is(
  wrap-text("foo bar baz quux test 123", :width(10), :prefix('--')),
  "--foo bar\n--baz quux\n--test 123",
  'no prefix'
);

done-testing;
