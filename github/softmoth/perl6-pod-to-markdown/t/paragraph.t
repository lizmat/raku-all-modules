use v6;

use Test;
use Pod::To::Markdown;

plan 1;

=begin pod
This is all
a paragraph.

This is the
next paragraph.

This is the
third paragraph.
=end pod

=para Abbreviated paragraph

=for para
Paragraph
paragraph

=begin para
Block

paragraph
=end para

is pod2markdown($=pod), q:to/EOF/, 'Paragraphs convert correctly';
This is all a paragraph.

This is the next paragraph.

This is the third paragraph.

Abbreviated paragraph

Paragraph paragraph

Block paragraph
EOF

# vim:set ft=perl6:
