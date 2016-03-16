use v6;
use Test;
use Algorithm::MinMaxHeap;

{
    my $heap = Algorithm::MinMaxHeap.new();
    $heap.insert(0);
    $heap.insert(1);
    $heap.insert(2);
    $heap.insert(3);
    $heap.insert(4);
    $heap.insert(5);
    $heap.insert(6);
    $heap.insert(7);
    $heap.insert(8);

    my @actual;
    while (not $heap.is-empty()) {
	@actual.push($heap.pop-min);
    }
    is @actual, [0,1,2,3,4,5,6,7,8];
}

done-testing;
