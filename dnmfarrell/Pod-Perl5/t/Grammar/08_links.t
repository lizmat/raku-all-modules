#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 13;

ok my $match = Pod::Perl5::Grammar.parsefile('test-corpus/links.pod'), 'parse links';

is $match<pod-section>[0]<paragraph>.elems, 11, 'Parser extracted eleven paragraphs';

is $match<pod-section>[0]<paragraph>[0]<multiline-text><format-code>[0]<name>.Str,
'Some::Name', 'Parser extract the correct name';

is $match<pod-section>[0]<paragraph>[1]<multiline-text><format-code>[0]<section>.Str,
'section', 'Parser extracted the correct section';

is $match<pod-section>[0]<paragraph>[2]<multiline-text><format-code>[0]<section>.Str,
'section', 'Parser extracted the correct section';

is $match<pod-section>[0]<paragraph>[3]<multiline-text><format-code>[0]<name>.Str,
'Some::Name', 'Parser extracted the correct name';

is $match<pod-section>[0]<paragraph>[4]<multiline-text><format-code>[0]<name>.Str,
'Some::Name', 'Parser extracted the correct name';

is $match<pod-section>[0]<paragraph>[5]<multiline-text><format-code>[0]<singleline-format-text>.Str,
'Some text', 'Parser extracted the correct text';

is $match<pod-section>[0]<paragraph>[6]<multiline-text><format-code>[0]<url>.Str,
'http://example.com', 'Parser extracted the url';
#
is $match<pod-section>[0]<paragraph>[7]<multiline-text><format-code>[0]<url>.Str,
'http://example.com', 'Parser extracted the url';

is $match<pod-section>[0]<paragraph>[8]<multiline-text><format-code>[0]<url>.Str,
'https://example.com', 'Parser extracted the url';

is $match<pod-section>[0]<paragraph>[9]<multiline-text><format-code>[0]<url>.Str,
'ftp://example.com', 'Parser extracted the url';

is $match<pod-section>[0]<paragraph>[10]<multiline-text><format-code>[0]<name>.Str,
'Some::Module', 'Parser extract the correct name';
