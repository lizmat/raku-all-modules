use Test;
use lib 'lib';

plan 14;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse-file('test-corpus/links.pod'), 'parse links';

is $match<pod-section>[0]<paragraph>.elems, 11, 'Parser extracted ten paragraphs';

is $match<pod-section>[0]<paragraph>[0]<paragraph_node>[0]<format-code><name>.Str,
'Some::Name', 'Parser extract the correct name';

is $match<pod-section>[0]<paragraph>[1]<paragraph_node>[0]<format-code><section>.Str,
'section', 'Parser extracted the correct section';

is $match<pod-section>[0]<paragraph>[2]<paragraph_node>[0]<format-code><section>.Str,
'section', 'Parser extracted the correct section';

is $match<pod-section>[0]<paragraph>[3]<paragraph_node>[0]<format-code><name>.Str,
'Some::Name', 'Parser extracted the correct name';

is $match<pod-section>[0]<paragraph>[4]<paragraph_node>[0]<format-code><name>.Str,
'Some::Name', 'Parser extracted the correct name';

is $match<pod-section>[0]<paragraph>[5]<paragraph_node>[0]<format-code><singleline_format_text>.Str,
'Some text', 'Parser extracted the correct text';

is $match<pod-section>[0]<paragraph>[6]<paragraph_node>[0]<format-code><url>.Str,
'http://example.com', 'Parser extracted the url';
#
is $match<pod-section>[0]<paragraph>[7]<paragraph_node>[0]<format-code><url>.Str,
'http://example.com', 'Parser extracted the url';

is $match<pod-section>[0]<paragraph>[8]<paragraph_node>[0]<format-code><url>.Str,
'https://example.com', 'Parser extracted the url';

is $match<pod-section>[0]<paragraph>[9]<paragraph_node>[0]<format-code><url>.Str,
'ftp://example.com', 'Parser extracted the url';

is $match<pod-section>[0]<paragraph>[10]<paragraph_node>[1]<format-code><name>.Str,
'Some::Module', 'Parser extract the correct name';

