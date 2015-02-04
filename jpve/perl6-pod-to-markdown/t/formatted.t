use v6;
BEGIN { @*INC.unshift: 'blib/lib', 'lib' }

use Test;
use Pod::To::Markdown;
plan 1;

my $markdown = q{This text is of _minor significance_.

This text is of *major significance*.

This text is of **fundamental significance**.

This text is verbatim C<with> B<disarmed> Z<formatting>.

This text is <var>to be replaced</var>.

This text is invisible.

This text contains a link to [http://www.google.com/](http://www.google.com/).};

is pod2markdown($=pod).trim, $markdown.trim,
    'Decodes formatted text correctly';

=begin pod
This text is of U<minor significance>.

This text is of I<major significance>.

This text is of B<fundamental significance>.

This text is V<verbatim C<with> B<disarmed> Z<formatting>>.

This text is R<to be replaced>.

This text is Z<blabla>invisible.

This text contains a link to L<http://www.google.com/>.
=end pod
