use v6;
use Test;

use Perl6::Literate;

is Perl6::Literate::convert(q[[[> my $a = "OH ";
> $a ~= "HAI";
> say $a;]]]),
   q[[[  my $a = "OH ";
  $a ~= "HAI";
  say $a;]]],
   'a program consisting only of code has all its ">" chars stripped';

done-testing;
