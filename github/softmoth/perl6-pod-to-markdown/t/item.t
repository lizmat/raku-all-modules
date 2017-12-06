use v6;

use Test;
use Pod::To::Markdown;

plan 1;

=begin pod
asdf

=item Abbreviated 1
=item Abbreviated 2

asdf

=for item
Paragraph
item

asdf

=begin item
Block
item
=end item

asdf

=item Abbreviated

=for item
Paragraph
item

=begin item
Block
item

with
multiple

paragraphs
=end item

asdf
=end pod

is pod2markdown($=pod), q:to/EOF/, 'Various types of items convert correctly';
asdf

  * Abbreviated 1

  * Abbreviated 2

asdf

  * Paragraph item

asdf

  * Block item

asdf

  * Abbreviated

  * Paragraph item

  * Block item

    with multiple

    paragraphs

asdf
EOF

# vim:set ft=perl6:
