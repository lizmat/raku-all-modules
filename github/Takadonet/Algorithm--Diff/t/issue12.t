use v6;
use Test;
plan 2;

# This test catches triggers the following error:
# Type check failed for return value; expected Int but got Mu (Mu)
#   in sub _replaceNextLargerWith at /home/alex/src/Algorithm--Diff/lib/Algorithm/Diff.pm (Algorithm::Diff) line 56
#   ...

use Algorithm::Diff;
my $a = "The Way that can be told of is not the eternal Way";
my $b = "The Tao that can be told of is not the eternal Tao";
my @alist = $a.split(/<|w>/);
my @blist = $b.split(/<|w>/);
my $diff = Algorithm::Diff.new(@alist, @blist);
my @from;
my @to;
while $diff.Next {
  if $diff.Same {
    @from.append($diff.Items(1));
    @to.append($diff.Items(2));
  } else {
    @from.push('<del>' ~ $diff.Items(1) ~ '</del>') if $diff.Items(1);
    @to.push('<ins>' ~ $diff.Items(2) ~ '</ins>') if $diff.Items(2);
  }
}
is @from.join(''), "The <del>Way</del> that can be told of is not the eternal <del>Way</del>", "deletions";
is @to.join(''), "The <ins>Tao</ins> that can be told of is not the eternal <ins>Tao</ins>", "insertions";

done-testing;
