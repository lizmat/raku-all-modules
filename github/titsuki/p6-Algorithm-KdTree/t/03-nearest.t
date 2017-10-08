use v6;
use Test;
use Algorithm::KdTree;


{
    my $kdtree = Algorithm::KdTree.new(2);
    loop (my $x = 0; $x <= 10; $x++) {
	loop (my $y = 0; $y <= 10; $y++) {
	    $kdtree.insert([$x.Num, $y.Num]);
	}
    }
    my $res = $kdtree.nearest([11e0,11e0]);
    is $res.is-end(), False, "It should have a response";
    is $res.get-position(), [10e0,10e0], "It should return a response which includes a element at the upper-right-most position";
}

{
    my $kdtree = Algorithm::KdTree.new(2);
    loop (my $x = 0; $x <= 10; $x++) {
	loop (my $y = 0; $y <= 10; $y++) {
	    $kdtree.insert([$x.Num, $y.Num]);
	}
    }
    my $res = $kdtree.nearest([-1e0,-1e0]);
    is $res.is-end(), False, "It should have a response";
    is $res.get-position(), [0e0,0e0], "It should return a response which includes a element at the bottom-left-most position";
}

{
    my $kdtree = Algorithm::KdTree.new(2);
    loop (my $x = 0; $x <= 10; $x++) {
	loop (my $y = 0; $y <= 10; $y++) {
	    $kdtree.insert([$x.Num, $y.Num]);
	}
    }
    my $res = $kdtree.nearest([4.5e0,4.9e0]);
    is $res.is-end(), False, "It should have a response";
    is $res.get-position(), [5e0,5e0], "It should return a response which includes a element at the center position"
}

{
    my $kdtree = Algorithm::KdTree.new(2);
    loop (my $x = 0; $x <= 10; $x++) {
	loop (my $y = 0; $y <= 10; $y++) {
	    $kdtree.insert([$x.Num, $y.Num]);
	}
    }
    my $res = $kdtree.nearest([5e0,5e0]);
    is $res.is-end(), False, "It should have a response";
    is $res.get-position(), [5e0,5e0], "When the target is on the same position of the query's one. It should return a response which includes a element at the center position";
}

done-testing;

