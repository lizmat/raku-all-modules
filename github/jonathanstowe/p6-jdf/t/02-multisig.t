use v6;
use Test;
use Printing::Jdf;

plan 7;

my $jdf = Printing::Jdf.new(slurp('t/MultiSigTest.jdf'));

is $jdf.ResourcePool.Layout<Signatures>.elems, 5, '5 signatures';
is $jdf.ResourcePool.Layout<Signatures>[3 - 1]<PressRun>, 3, 'is run 3';

my $eight = <08%20CustomSig%20380x275.tpl>;
my $sixteen = <16%20CustomSig%20380x275%20on%20800s.tpl>;
my $s = $jdf.ResourcePool.Layout<Signatures>;

is $s[1-1]<Template>.basename, $eight, 'eight page template';
is $s[2-1]<Template>.basename, $sixteen, 'sixteen page template';
is $s[3-1]<Template>.basename, $sixteen, 'sixteen page template';
is $s[4-1]<Template>.basename, $sixteen, 'sixteen page template';
is $s[5-1]<Template>.basename, $sixteen, 'sixteen page template';

# vim: ft=perl6
