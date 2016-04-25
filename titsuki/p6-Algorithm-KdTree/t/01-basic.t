use v6;
use Test;
use Algorithm::KdTree;

{
    lives-ok { my $kdtree = Algorithm::KdTree.new(3); }
}

done-testing;
