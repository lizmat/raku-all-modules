use v6;
use Test;

use Perl6::Literate;

is Perl6::Literate::convert(q[[[Here is some text.

> say 'OH HAI';]]]),
   q[[[=begin Comment
Here is some text.
=end Comment

  say 'OH HAI';]]],
   'comment and then code';

done;
