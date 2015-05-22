use Test;
use lib 'lib';

plan 4;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse-file('test-corpus/command.pod'), 'parse command';

is $match<pod-section>[0]<command-block>.elems, 3, 'Parser extracted three command paragraphs';

is $match<pod-section>[0]<command-block>[1]<name>.Str, 'utf8', 'Parser extracted encoding name is utf8';
  'Parser extracted the paragraph';

