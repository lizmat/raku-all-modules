use v6;
use Test;
use Algorithm::MinMaxHeap;
use Algorithm::MinMaxHeap::Comparable;

subtest {
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

    is $heap.nodes[0] < $heap.nodes[3], True;
    is $heap.nodes[0] < $heap.nodes[4], True;
    is $heap.nodes[0] < $heap.nodes[5], True;
    is $heap.nodes[0] < $heap.nodes[6], True;
    
    is $heap.nodes[1] > $heap.nodes[7], True;
    is $heap.nodes[1] > $heap.nodes[8], True;
    is $heap.nodes[0], 0;
    is max($heap.nodes[1], $heap.nodes[2]), 8;
}, "Given a constructor with a Int parameter, it should insert Int items";

subtest {
    my $heap = Algorithm::MinMaxHeap[Int].new;
    dies-ok { $heap.insert(1.5); }
}, "Given a constructor with a Int parameter, it shouldn't insert Rat items";

subtest {
    my subset MyCool of Cool where Int|Num|Rat;
    my $heap = Algorithm::MinMaxHeap[MyCool].new;
    $heap.insert(0);
    $heap.insert(1.1e0);
    $heap.insert(2);
    $heap.insert(3.1e0);
    $heap.insert(4);
    $heap.insert(5);
    $heap.insert(6);
    $heap.insert(7.1);
    $heap.insert(8); 

    is $heap.nodes[0] < $heap.nodes[3], True;
    is $heap.nodes[0] < $heap.nodes[4], True;
    is $heap.nodes[0] < $heap.nodes[5], True;
    is $heap.nodes[0] < $heap.nodes[6], True;
    
    is $heap.nodes[1] > $heap.nodes[7], True;
    is $heap.nodes[1] > $heap.nodes[8], True;
    is $heap.nodes[0], 0;
    is max($heap.nodes[1], $heap.nodes[2]), 8;
}, "Given a constructor with a MyCool(i.e. Int|Num|Rat) parameter, It should insert Int/Num/Rat items";

subtest {
    my subset MyCool of Cool where Int|Num|Rat;
    my $heap = Algorithm::MinMaxHeap[MyCool].new;
    dies-ok { $heap.insert("Perl6 is fun"); }
}, "Given a constructor with a MyCool(i.e. Int|Num|Rat) parameter, It shouldn't insert Str items";

subtest {
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
    
    $heap.insert(State.new(value => 8));
    $heap.insert(State.new(value => 0));
    $heap.insert(State.new(value => 1));
    $heap.insert(State.new(value => 2));
    $heap.insert(State.new(value => 3));
    $heap.insert(State.new(value => 4));
    $heap.insert(State.new(value => 5));
    $heap.insert(State.new(value => 6));
    $heap.insert(State.new(value => 7));

    is $heap.nodes[0].compare-to($heap.nodes[3]) == Order::Less, True;
    is $heap.nodes[0].compare-to($heap.nodes[4]) == Order::Less, True;
    is $heap.nodes[0].compare-to($heap.nodes[5]) == Order::Less, True;
    is $heap.nodes[0].compare-to($heap.nodes[6]) == Order::Less, True;
    
    is $heap.nodes[1].compare-to($heap.nodes[7]) == Order::More, True;
    is $heap.nodes[1].compare-to($heap.nodes[8]) == Order::More, True;
    is $heap.nodes[0].value, 0;
    is max($heap.nodes[1].value, $heap.nodes[2].value), 8;
}, "Given a constructor with a Algorithm::MinMaxHeap::Comparable parameter, It should insert Algorithm::MinMaxHeap::Comparable items";

subtest {
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
    dies-ok { $heap.insert(1); }
}, "Given a constructor with a Algorithm::MinMaxHeap::Comparable parameter, It shouldn't insert Int items";

done-testing;
