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

    is $heap.nodes[0] < $heap.nodes[3], True;
    is $heap.nodes[0] < $heap.nodes[4], True;
    is $heap.nodes[0] < $heap.nodes[5], True;
    is $heap.nodes[0] < $heap.nodes[6], True;
    
    is $heap.nodes[1] > $heap.nodes[7], True;
    is $heap.nodes[1] > $heap.nodes[8], True;
    is $heap.nodes[0], 0;
    is max($heap.nodes[1], $heap.nodes[2]), 8;
}

done-testing;
