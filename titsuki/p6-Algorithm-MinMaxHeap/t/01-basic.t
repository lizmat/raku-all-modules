use v6;
use Test;
use Algorithm::MinMaxHeap;

lives-ok { my $heap = Algorithm::MinMaxHeap[Int].new; }
lives-ok { my $heap = Algorithm::MinMaxHeap[Cool].new }
lives-ok { my $heap = Algorithm::MinMaxHeap[Algorithm::MinMaxHeap::Comparable].new; }
lives-ok { my $heap = Algorithm::MinMaxHeap[Str].new }
lives-ok { my $heap = Algorithm::MinMaxHeap[Rat].new }
lives-ok { my $heap = Algorithm::MinMaxHeap[Num].new }
lives-ok { my $heap = Algorithm::MinMaxHeap[Real].new }
lives-ok { my $heap = Algorithm::MinMaxHeap[Any].new }
lives-ok { my $heap = Algorithm::MinMaxHeap[Mu].new }
lives-ok { my $heap = Algorithm::MinMaxHeap[Instant].new }

done-testing;
