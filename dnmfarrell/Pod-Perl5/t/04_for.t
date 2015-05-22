use Test;
use lib 'lib';

plan 5;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse-file('test-corpus/for.pod'), 'parse for command';

is $match<pod-section>[0]<command-block>.elems, 1, 'Parser extracted one for';
is $match<pod-section>[0]<command-block>[0]<name>.Str, 'HTML', 'Parser extracted name value is HTML';
is $match<pod-section>[0]<command-block>[0]<singleline_text>.Str, "<a href='#'>some inline hyperlink</a>", 
  'Parser extracted the paragraph';
