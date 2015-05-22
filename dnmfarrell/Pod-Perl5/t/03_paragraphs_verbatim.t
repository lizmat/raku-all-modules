use Test;
use lib 'lib';

plan 5;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse-file('test-corpus/paragraphs_advanced.pod'),
  'parse paragraphs with verbatim example';

is $match<pod-section>[0]<paragraph>.elems, 2,
  'Parser extracted two paragraphs';

is $match<pod-section>[0]<verbatim_paragraph>.elems, 1,
  'Parser extracted one verbatim paragraph';

is $match<pod-section>[0]<verbatim_paragraph>[0]<verbatim_text>.Str,
  qq/  use strict;\n  print "Hello, World!\\n";\n/, # escape the literal newline
  'Parser extracted the verbatim text';

