use lib 'lib';
use Test;
use Games::TauStation::DateTime;

plan 303;

is GCT.new('1964-01-22T00:00:27.689615Z'), '000.00/00:000 GCT',
    'Catastrophe time Old Earth -> GCT';
is GCT.new('000.00/00:000 GCT').OE, '1964-01-22T00:00:27.689615Z',
    'Catastrophe time GCT -> Old Earth';

is GCT.new('198.15/03:973 GCT').OE, '2018-04-23T00:57:13.361615Z',
    'some GCT date to OE';

for ^100 {
    my $t := 1524424977.922727.rand.Rat;
    is GCT.new($t).OE,       DateTime.new($t), ".OE with time $t";
    is GCT.new($t).OldEarth, DateTime.new($t), ".OldEarth with time $t";
    is-deeply GCT.new($t).DateTime, DateTime.new($t),
        ".DateTime with time $t";
}
