use Test;
use lib 'lib';

plan 10;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse-file('test-corpus/readme_example.pod'),
  'parse readme example';

# basic counts
is $match<pod-section>.elems,                       1, 'Parser extracted one pod section';
is $match<pod-section>[0]<command-block>.elems,     12, 'Parser extracted command blocks';
is $match<pod-section>[0]<paragraph>.elems,         6, 'Parser extracted six paragraphs';
is $match<pod-section>[0]<verbatim_paragraph>.elems,4, 'Parser extracted four verbatim paragraphs';

# value checks
is $match<pod-section>[0]<command-block>[5]<singleline_text>.Str,
  "SYNOPSIS",
  'Parser extracted name from header';

is $match<pod-section>[0]<paragraph>[2]<paragraph_node>.Str,
  "0.01\n",
  'Parser extracted text from paragraph';

is $match<pod-section>[0]<paragraph>[3]<paragraph_node>[3]<format-code><multiline_text>.Str,
  "Pod::Perl5::Grammar",
  'Parser extracted value from code formatting';

is $match<pod-section>[0]<verbatim_paragraph>[0]<verbatim_text>.Str,
  "  use Pod::Perl5;\n",
  'Parser extracted text from verbatim paragraph';
