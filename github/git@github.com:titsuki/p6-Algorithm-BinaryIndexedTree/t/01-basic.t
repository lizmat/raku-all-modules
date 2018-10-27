use v6;
use Test;
use Algorithm::BinaryIndexedTree;

subtest {
    my $BIT = Algorithm::BinaryIndexedTree.new();
    $BIT.add(5,10);
    is $BIT.get(4), 0, "when it gets tree[4] then it should return 0";
    is $BIT.get(5), 10, "when it gets tree[5] then it should return 10";
    
    is $BIT.sum(4), 0, "when it sums tree[0..4] then it should return 0";
    is $BIT.sum(5), 10, "when it sums tree[0..5] then it should return 10";
    is $BIT.sum(6), 10, "when it sums tree[0..6] then it should return 10";
}, "Given: It adds value 10 to tree[5]";

subtest {
    my $BIT = Algorithm::BinaryIndexedTree.new();
    $BIT.add(0,10);
    dies-ok { $BIT.get(-1); }, "when it gets tree[-1] then it should die";
    is $BIT.get(0), 10, "when it gets tree[0] then it should return 10 ";
    is $BIT.get(1), 0, "when it gets tree[1] then it should return 0";
    
    dies-ok { $BIT.sum(-1); }, "when it sums tree[-1] then it should die";
    is $BIT.sum(0), 10, "when it sums tree[0..0] then it should return 10";
    is $BIT.sum(1), 10, "when it sums tree[0..1] then it should return 10";
}, "Given: It adds value 10 to tree[0]";

subtest {
    my $BIT = Algorithm::BinaryIndexedTree.new();
    $BIT.add(5,10);
    $BIT.add(5,10);

    is $BIT.get(4), 0, "when it gets tree[4] then it should return 0";
    is $BIT.get(5), 20, "when it gets tree[5] then it should return 20";
    
    is $BIT.sum(4), 0, "when it sums tree[0..4] then it should return 0";
    is $BIT.sum(5), 20, "when it sums tree[0..5] then it should return 20";
    is $BIT.sum(6), 20, "when it sums tree[0..6] then it should return 20";
}, "Given: It adds value 10 to tree[5] twice";

subtest {
     my $BIT = Algorithm::BinaryIndexedTree.new();
    $BIT.add(0,10);
    $BIT.add(0,10);

    dies-ok { $BIT.get(-1); }, "when it gets tree[-1] then it should die";
    is $BIT.get(0), 20, "when it gets tree[0] then it should return 20";
    is $BIT.get(1), 0, "when it gets tree[1] then it should return 0";
    
    dies-ok { $BIT.sum(-1); }, "when it sums tree[-1] then it should die";
    is $BIT.sum(0), 20, "when it sums tree[0..0] then it should return 20";
    is $BIT.sum(1), 20, "when it sums tree[0..1] then it should return 20";
}, "Given: It adds value 10 to tree[0] twice";

subtest {
    my $BIT = Algorithm::BinaryIndexedTree.new(size => 1000);
    $BIT.add(999,10);
    $BIT.add(1000,10);
    dies-ok { $BIT.add(1001,10); }, "when it adds value 10 to tree[1001] then it should die";

    is $BIT.sum(1000),20, "when it sums tree[0..1000] then it should return 20";
    dies-ok { $BIT.sum(1001); }, "when it sums tree[0..1001] then it should die";
}, "Given: BIT size is 1000";

done-testing;
