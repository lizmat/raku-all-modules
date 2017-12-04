use v6;
use lib <blib/lib lib>;

use Test;
use Pod::To::Markdown;

plan 1;

my $markdown = q{asdf

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

asdf};

is pod2markdown($=pod).trim, $markdown.trim,
   'Various types of items convert correctly';


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
