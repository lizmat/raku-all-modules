use v6;
use Test;
use Printing::Jdf;

plan 2;

my $jdf = Printing::Jdf.new(slurp('t/MultiSigTest.jdf'));
my $page42 = $jdf.ResourcePool.Runlist[42 - 1];
is $page42<Centered>, True, 'is centered';
is $page42<Offsets>, { X => -3, Y => -3}, 'offsets correct';


# vim: ft=perl6
