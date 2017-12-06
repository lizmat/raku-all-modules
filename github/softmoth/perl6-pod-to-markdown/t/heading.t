use v6;

use Test;
use Pod::To::Markdown;

plan 1;

=begin pod
=head1 Abbreviated heading

asdf

=for head1
Paragraph heading

asdf

=begin head1
Delimited

heading
=end head1



asdf

=head2 Head2

asdf

=head3 Head3

asdf

=head4 Head4

asdf

=end pod


is pod2markdown($=pod), q:to/EOF/, 'Various types of headings convert correctly';
Abbreviated heading
===================

asdf

Paragraph heading
=================

asdf

Delimited heading
=================

asdf

Head2
-----

asdf

### Head3

asdf

#### Head4

asdf
EOF

# vim:set ft=perl6:
