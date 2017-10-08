use v6;
use Test;
use Algorithm::MinMaxHeap;

{
    my $heap = Algorithm::MinMaxHeap[Int].new;
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
    is @actual, [0,1,2,3,4,5,6,7,8], "It should return ascending array";
}

{
    my $heap = Algorithm::MinMaxHeap[Int].new;
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
        @actual.push($heap.pop-min);
    }
    is @actual, [0,1,1,3,4,5,6,7,8], "Given a input including duplicated items. It should return ascending array";
}

{
    my class State {
        also does Algorithm::MinMaxHeap::Comparable[State];
        has Int $.value;
        has $.payload;
        submethod BUILD(:$!value) { }
        method compare-to(State $s) {
            if (self.value == $s.value) {
                return Order::Same;
            }
            if (self.value > $s.value) {
                return Order::More;
            }
            if (self.value < $s.value) {
                return Order::Less;
            }
        }
    }
    
    my $heap = Algorithm::MinMaxHeap[Algorithm::MinMaxHeap::Comparable].new;

    $heap.insert(State.new(value => 0));
    $heap.insert(State.new(value => 1));
    $heap.insert(State.new(value => 2));
    $heap.insert(State.new(value => 3));
    $heap.insert(State.new(value => 4));
    $heap.insert(State.new(value => 5));
    $heap.insert(State.new(value => 6));
    $heap.insert(State.new(value => 7));
    $heap.insert(State.new(value => 8));

    my @actual;
    while (not $heap.is-empty()) {
        @actual.push($heap.pop-min.value);
    }
    is @actual, [0,1,2,3,4,5,6,7,8], "It should return ascending array";
}

done-testing;
