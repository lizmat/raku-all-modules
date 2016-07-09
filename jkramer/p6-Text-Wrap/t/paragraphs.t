
use Test;

use lib 'lib';

use Text::Wrap;

plan 2;

is(
  wrap-text("foo\nbar\nbaz\n\n123\n 456 789", :width(80)),
  "foo bar baz\n\n123 456 789",
  'keep paragraphs'
);

is(
  wrap-text("foo\nbar\nbaz\n\n123\n 456 789", :width(80), :paragraph(Regex:U)),
  "foo bar baz 123 456 789",
  'discard paragraphs'
);

done-testing;
