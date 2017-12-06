use v6;

use Test;
use Pod::To::Markdown;
plan 1;

is pod2markdown($=pod), q:to/EOF/, 'Properly deals with code that contains backticks in it';
Here is a single backtick `` ` ``.

Here is two backticks ``` `` ```.

Here is one ```` ```perl6```` with three.
EOF


=begin pod
Here is a single backtick C<`>.

Here is two backticks C<``>.

Here is one C<```perl6> with three.
=end pod

# vim:set ft=perl6:
