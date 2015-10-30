use v6;
BEGIN { @*INC.unshift: 'blib/lib', 'lib' }

use Test;
use Pod::To::Markdown;

plan 1;

my $markdown = q{This is all a paragraph.

This is the next paragraph.

This is the third paragraph.

Abbriviated paragraph

Paragraph paragraph

Block paragraph};

is pod2markdown($=pod), $markdown,
    'Paragraphs convert correctly.';

=begin pod
This is all
a paragraph.

This is the
next paragraph.

This is the
third paragraph.
=end pod

=para Abbriviated paragraph

=for para
Paragraph
paragraph

=begin para
Block

paragraph
=end para
