use v6;
use Test;
use Algorithm::MinMaxHeap;

lives-ok { my $heap = Algorithm::MinMaxHeap.new(); }
lives-ok { my $heap = Algorithm::MinMaxHeap.new(type => Cool); }
lives-ok { my $heap = Algorithm::MinMaxHeap.new(type => Algorithm::MinMaxHeap::Comparable); }
lives-ok { my $heap = Algorithm::MinMaxHeap.new(type => Str); }
lives-ok { my $heap = Algorithm::MinMaxHeap.new(type => Rat); }
lives-ok { my $heap = Algorithm::MinMaxHeap.new(type => Int); }
lives-ok { my $heap = Algorithm::MinMaxHeap.new(type => Num); }
lives-ok { my $heap = Algorithm::MinMaxHeap.new(type => Real); }
dies-ok { my $heap = Algorithm::MinMaxHeap.new(type => Range); }, "It shouldn't set Range";
dies-ok { my $heap = Algorithm::MinMaxHeap.new(type => Any); }, "It shouldn't set Any";
dies-ok { my $heap = Algorithm::MinMaxHeap.new(type => Mu); }, "It shouldn't set Mu";
dies-ok { my $heap = Algorithm::MinMaxHeap.new(type => Numeric); }, "It shouldn't set Numeric";


{
    my $heap = Algorithm::MinMaxHeap.new();
    is $heap.type, Int, "It should be Int";
}

{
    my $heap = Algorithm::MinMaxHeap.new(type => Cool);
    is $heap.type, Cool, "It should be Cool";
}

{
    my $heap = Algorithm::MinMaxHeap.new(type => Algorithm::MinMaxHeap::Comparable);
    is $heap.type, Algorithm::MinMaxHeap::Comparable, "It should be Comparable";
}

{
    my $heap = Algorithm::MinMaxHeap.new(type => Str);
    is $heap.type, Str, "It should be Str";
}

{
    my $heap = Algorithm::MinMaxHeap.new(type => Rat);
    is $heap.type, Rat, "It should be Rat";
}

{
    my $heap = Algorithm::MinMaxHeap.new(type => Num);
    is $heap.type, Num, "It should be Num";
}

{
    my $heap = Algorithm::MinMaxHeap.new(type => Real);
    is $heap.type, Real, "It should be Real";
}

done-testing;
