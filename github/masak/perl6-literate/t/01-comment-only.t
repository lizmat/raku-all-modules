use v6;
use Test;

use Perl6::Literate;

is Perl6::Literate::convert("A\nB\n\nC"),
   "=begin Comment\nA\nB\n\nC\n=end Comment\n",
   'a program consisting only of a comment gets converted into Pod';

done-testing;
