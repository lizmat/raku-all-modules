use v6;

use Test;
use Pod::To::Markdown;

plan 1;

=begin pod
I like traffic lights.

=comment Tendentious stuff!

But not when they are red.
=end pod

is pod2markdown($=pod), q:to/EOF/, 'Comments disappear';
I like traffic lights.

But not when they are red.
EOF

# vim:set ft=perl6:
