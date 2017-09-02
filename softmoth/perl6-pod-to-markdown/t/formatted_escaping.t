use v6;
use lib <blib/lib lib>;

use Test;
use Pod::To::Markdown;
plan 1;

my $markdown = Q:to/ENDing/;
Here is a single backtick `` ` ``.

Here is two backticks ``` `` ```.

Here is one ```` ```perl6```` with three.
ENDing

is pod2markdown($=pod).trim, $markdown.chomp,
    'Properly deals with code that contains backticks in it';

=begin pod
Here is a single backtick C<`>.

Here is two backticks C<``>.

Here is one C<```perl6> with three.

=end pod
