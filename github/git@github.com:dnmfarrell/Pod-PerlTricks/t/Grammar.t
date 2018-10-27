#!/usr/bin/env perl6
# These are tests for the PerlTricks pseudopod grammar

use Test;
use lib 'lib';

plan 19;

use Pod::PerlTricks::Grammar; pass 'import module';

ok my $match
  = Pod::PerlTricks::Grammar.parsefile('test-corpus/SampleArticle.pod'),
  'parse sample article';

ok my $pod = $match<pod-section>[0], "match pod section";

is $pod<command-block>[2]<format-code><url>, 'file://onion_charcoal.png', 'cover-image url';

is $pod<command-block>[3]<singleline-text>.Str,
  'Separate data and behavior with table-driven testing',
  'title';

is $pod<command-block>[4]<singleline-text>.Str,
  'Applying DRY to unit testing',
  'subtitle';

is $pod<command-block>[6]<datetime>.Str,
  '2000-12-31T00:00:00',
  'publish-date';

is my $include = $pod<command-block>[7]<format-code>[0]<url>.Str,
  'file://test-corpus/briandfoy.pod',
  'Match filepath of include directive';

is $pod<command-block>[8]<name>.elems, 6, '6 tags found';
is $pod<command-block>[8]<name>[3], 'table', 'matched table tag';

# paragraph tests
is $pod<paragraph>.elems, 16, 'matched all paragraphs';
is $pod<paragraph>[0]<multiline-text><format-code>[0].Str,
  'N<This is known as W<data-driven-testing>>',
  'match note text';
is $pod<paragraph>[0]<multiline-text><format-code>[0]<format-text><format-code>[0].Str,
  'W<data-driven-testing>',
  'Match Wiki text';

is $pod<paragraph>[13]<multiline-text><format-code>[1].Str,
  'D<tests.t>',
  'Match Data format code text';

is $pod<verbatim-paragraph>.elems, 7, 'matched all verbatim paragraphs';

ok my $table = $pod<command-block>[9], 'table';
is $table<header-row><header-cell>.elems, 3, 'match 3 headings';
is $table<header-row><header-cell>[2].Str, 'ColC', 'match third heading';
is $table<row>[1]<cell>[1].Str, '1234', 'match middle cell';
