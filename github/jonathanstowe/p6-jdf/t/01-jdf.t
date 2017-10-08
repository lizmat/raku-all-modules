use v6;
use Test;
use Printing::Jdf;

plan 31;

is Printing::Jdf::mm(14.1732), 5.0, 'convert points to mm';
is Printing::Jdf::mm("14.1732"), 5.0, 'convert str points to mm';
is Printing::Jdf::mm(-14.1732), -5.0, 'convert negative points to mm';
is Printing::Jdf::mm("-14.1732"), -5.0, 'convert negative str points to mm';
is Printing::Jdf::mm(42), 15, 'convert pt to mm';
is Printing::Jdf::mm(5), 2, 'pearl';
is Printing::Jdf::mm(12), 4, 'pica';
is Printing::Jdf::mm(24), 8, 'double pica';
is Printing::Jdf::mm(48), 17, 'canon';
is Printing::Jdf::mm(72), (25.4).round, '1 inch';

my Printing::Jdf $jdf = Printing::Jdf.new(slurp('t/TestJobFile.jdf'));

is $jdf.AuditPool.Created<AgentName>, 'Kodak Preps', 'agent name is correct';
is $jdf.AuditPool.Created<AgentVersion>,'5.3.3  (595)','agent version correct';
# 2014-07-02T04:55:31+12:45
is $jdf.AuditPool.Created<TimeStamp>, DateTime.new(
    year => 2014, month => 7, day => 2, hour => 4, minute => 55, second => 31,
    timezone => ((12 * 60) + 45) * 60), 'timestamp correct';

is $jdf.ResourcePool.ColorantOrder, <Cyan Magenta Yellow Black>, 'colour order';
is $jdf.ResourcePool.Layout<Bleed>, 5, 'bleed is correct';
is $jdf.ResourcePool.Layout<PageAdjustments><Odd><X>, 100, 'odd x';
is $jdf.ResourcePool.Layout<PageAdjustments><Odd><Y>, 200, 'odd y';
is $jdf.ResourcePool.Layout<PageAdjustments><Even><X>, 300, 'even x';
is $jdf.ResourcePool.Layout<PageAdjustments><Even><Y>, 400, 'even y';
is $jdf.ResourcePool.Layout<Signatures>.elems, 1, '1 signature';
is $jdf.ResourcePool.Layout<Signatures>[0]<Name>, "1", 'signature name';
is $jdf.ResourcePool.Layout<Signatures>[0]<PressRun>, 1, 'signature run';

my $runlist = $jdf.ResourcePool.Runlist;
is $runlist.elems, 28, '28 files';
my $page7 = $runlist[7 - 1];
is $page7<Page>, 7, 'is page 7';
is $page7<Url>.basename, '007-NEW%20WORLD%20FULLPAGE.pdf', 'page 7 filename';
is $page7<CenterOffset>, {X => 0, Y => 0}, 'page 7 center offset';
is $page7<Centered>, False, 'page 7 not centered';
is $page7<Offsets>, { X => 0, Y => 0 }, 'page 7 runlist offsets';
is $page7<Scaling>, { X => 100, Y => 100 }, 'page 7 scaling';

is Printing::Jdf::ResourcePool::parseOffset("27 -11"), {X => 10, Y => -4}, 'parseOffset';
is Printing::Jdf::ResourcePool::parseScaling("0.97 0.85"), {X => 97, Y => 85}, 'scaling';

# vim: ft=perl6
