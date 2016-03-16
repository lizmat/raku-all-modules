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
	@actual.push($heap.pop-max);
    }
    is @actual, [8,7,6,5,4,3,2,1,0];
}

{
    my $heap = Algorithm::MinMaxHeap.new();
    $heap.insert(0);
    $heap.insert(1);
    $heap.insert(1);
    $heap.insert(3);
    $heap.insert(4);
    $heap.insert(5);
    $heap.insert(6);
    $heap.insert(7);
    $heap.insert(8);

    my @actual;
    while (not $heap.is-empty()) {
	@actual.push($heap.pop-max);
    }
    is @actual, [8,7,6,5,4,3,1,1,0];
}

done-testing;
