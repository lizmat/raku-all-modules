use v6;
use Test;
use Algorithm::SetUnion;

lives-ok { Algorithm::SetUnion.new(size => 0); }
lives-ok { Algorithm::SetUnion.new(size => 100000); }

{
    my $set-union = Algorithm::SetUnion.new(size => 5);
    $set-union.union(0,1);
    is $set-union.find(0) == $set-union.find(1), True;
}

{
    my $set-union = Algorithm::SetUnion.new(size => 5);
    $set-union.union(0,1);
    $set-union.union(1,2);
    is $set-union.find(0) == $set-union.find(1), True;
    is $set-union.find(1) == $set-union.find(2), True;
}

{
    my $set-union = Algorithm::SetUnion.new(size => 5);
    $set-union.union(0,1);
    $set-union.union(2,3);
    is $set-union.find(0) == $set-union.find(1), True;
    is $set-union.find(2) == $set-union.find(3), True;
    is $set-union.find(0) == $set-union.find(2), False;
    is $set-union.find(0) == $set-union.find(3), False;
    is $set-union.find(1) == $set-union.find(2), False;
    is $set-union.find(1) == $set-union.find(3), False;
}

done-testing;
