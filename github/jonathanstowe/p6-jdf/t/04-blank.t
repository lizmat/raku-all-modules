use v6;
use Test;
use Printing::Jdf;

plan 3;

my Printing::Jdf $jdf = Printing::Jdf.new(slurp('t/BlankPageTest.jdf'));

my $runlist = $jdf.ResourcePool.Runlist;
my $page2 = $runlist[2 - 1];

is $page2<Url>.basename, 'Blank Page', 'page name is "Blank Page"';
is $page2<IsBlank>, True, 'attribute indicates page is blank';

$jdf = Printing::Jdf.new(slurp('t/TestJobFile.jdf'));
$runlist = $jdf.ResourcePool.Runlist;
$page2 = $runlist[2 - 1];

is $page2<IsBlank>, False, 'attribute indicates page is not blank';

# vim: ft=perl6
