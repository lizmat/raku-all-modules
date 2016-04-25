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
    my $res = $kdtree.nearest-range([11e0,11e0], sqrt(2e0) - 1e-9);
    is $res.is-end(), True, "It should return empty response when the radius is short";
}

{
    my $kdtree = Algorithm::KdTree.new(2);
    loop (my $x = 0; $x <= 10; $x++) {
	loop (my $y = 0; $y <= 10; $y++) {
	    $kdtree.insert([$x.Num, $y.Num]);
	}
    }
    my $res = $kdtree.nearest-range([11e0,11e0], sqrt(2e0));
    is $res.is-end(), False, "It should have a response";
    is $res.get-position(), [10e0,10e0], "When the target is on the line. It should return a response which includes a element at the upper-right-most position";
}

{
    my $kdtree = Algorithm::KdTree.new(2);
    loop (my $x = 0; $x <= 10; $x++) {
	loop (my $y = 0; $y <= 10; $y++) {
	    $kdtree.insert([$x.Num, $y.Num]);
	}
    }
    my $res = $kdtree.nearest-range([11e0,11e0], sqrt(2e0) + 1e-9);
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
    my $res = $kdtree.nearest-range([-1e0,-1e0], sqrt(2e0) - 1e-9);
    is $res.is-end(), True, "It should return empty response when the radius is short";
}

{
    my $kdtree = Algorithm::KdTree.new(2);
    loop (my $x = 0; $x <= 10; $x++) {
	loop (my $y = 0; $y <= 10; $y++) {
	    $kdtree.insert([$x.Num, $y.Num]);
	}
    }
    my $res = $kdtree.nearest-range([-1e0,-1e0], sqrt(2e0));
    is $res.is-end(), False, "It should have a response";
    is $res.get-position(), [0e0,0e0], "When the target is on the line. It should return a response which includes a element at the bottom-left-most position";
}

{
    my $kdtree = Algorithm::KdTree.new(2);
    loop (my $x = 0; $x <= 10; $x++) {
	loop (my $y = 0; $y <= 10; $y++) {
	    $kdtree.insert([$x.Num, $y.Num]);
	}
    }
    my $res = $kdtree.nearest-range([-1e0,-1e0], sqrt(2e0) + 1e-9);
    is $res.is-end(), False, "It should have a response";
    is $res.get-position(), [0e0,0e0], "It should return a response which includes a element at the bottom-left-most position";
}

{
    my $kdtree = Algorithm::KdTree.new(2);
    my @expected;
    loop (my $x = 0; $x <= 10; $x++) {
	loop (my $y = 0; $y <= 10; $y++) {
	    $kdtree.insert([$x.Num, $y.Num]);
	    @expected.push([$x.Num, $y.Num]);
	}
    }
    my $res = $kdtree.nearest-range([0e0,0e0], 10000e0);
    my @actual;
    while (not $res.is-end()) {
	@actual.push($res.get-position());
	$res.next();
    }
    is @actual.sort, @expected.sort, "It should have all elements";
}

done-testing;
