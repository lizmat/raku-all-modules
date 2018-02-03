
use Test;

use lib 'lib';

use Text::Wrap;

plan 3;

is(
  wrap-text("foo bar baz quux test 123", :width(10)),
  "foo bar\nbaz quux\ntest 123",
  'no prefix'
);

is(
  wrap-text("foo bar baz quux test 123", :width(10), :prefix('--')),
  "--foo bar\n--baz quux\n--test 123",
  '-- as prefix'
);

my $spaces = '-' x 3;
is(
    wrap-text("foo bar baz quux test 123", :width(10), :prefix( $spaces )),
    $spaces~"foo bar\n"~$spaces~"baz\n"~$spaces~"quux\n"~$spaces~"test\n"~$spaces~"123",
    'Spaces as prefix'
);

done-testing;
