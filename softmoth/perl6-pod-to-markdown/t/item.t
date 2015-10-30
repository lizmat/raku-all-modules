use v6;
BEGIN { @*INC.unshift: 'blib/lib', 'lib' }

use Test;
use Pod::To::Markdown;

plan 1;

my $markdown = q{asdf

  * Abbriviated 1

  * Abbriviated 2

asdf

  * Paragraph item

asdf

  * Block item

asdf

  * Abbriviated

  * Paragraph item

  * Block item

    with multiple

    paragraphs

asdf};

is pod2markdown($=pod).trim, $markdown.trim,
   'Various types of items convert correctly';


=begin pod
asdf

=item Abbriviated 1
=item Abbriviated 2

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

=item Abbriviated

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
