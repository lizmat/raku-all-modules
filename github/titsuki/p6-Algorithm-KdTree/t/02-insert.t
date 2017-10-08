use v6;
use Test;
use Algorithm::KdTree;

{
    my $kdtree = Algorithm::KdTree.new(3);
    dies-ok { $kdtree.insert(["hoge","piyo","fuga"])}, "It shouldn't insert a Str array"; 
}

{
    my $kdtree = Algorithm::KdTree.new(3);
    dies-ok { $kdtree.insert([1,1,1]); }, "It shouldn't insert a Int array";
}

{
    my $kdtree = Algorithm::KdTree.new(3);
    dies-ok { $kdtree.insert([1e0]); }, "It shouldn't insert a array having different dimension from the kd-tree's one";
}

{
    my $kdtree = Algorithm::KdTree.new(3);
    lives-ok { $kdtree.insert([1e0,1e0,1e0]); }, "It should insert a array having same dimension of the kd-tree's one";
}

{
    my $kdtree = Algorithm::KdTree.new(512);
    my @array <== map { .Num } <== (1..512);
    lives-ok { $kdtree.insert(@array); }, "It should insert a huge array";
}

done-testing;
