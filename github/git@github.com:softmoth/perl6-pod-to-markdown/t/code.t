use v6;

use Test;
use Pod::To::Markdown;

plan 1;

=begin pod
asdf

    indented

asdf

    indented
    multi
    line

asdf

    indented
    multi
    line

    and
    broken
    up

asdf

=code Abbreviated

asdf

=for code
Paragraph
code

asdf

=begin code
Delimited
code
=end code

asdf
=end pod

is pod2markdown($=pod), q:to/EOF/, 'Various types of code blocks convert correctly.';
asdf

    indented

asdf

    indented
    multi
    line

asdf

    indented
    multi
    line

    and
    broken
    up

asdf

    Abbreviated

asdf

    Paragraph
    code

asdf

    Delimited
    code

asdf
EOF

# vim:set ft=perl6:
