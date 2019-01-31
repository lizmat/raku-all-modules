# causes SEGVs RT#131510    use lib <lib>;
use Testo;
use Temp::Path;
plan 4;

group 'file' => 2 => {
    my $file = make-temp-path :content<foo>;
    is $file, :e .Pair, 'exists before DESTROY';
    $file.DESTROY;
    await Promise.in(1); # cause .DESTROY is async
    is $file, :!e.Pair, 'does not exist after DESTROY';
}

group 'file, after changing path' => 2 => {
    temp $*TMPDIR = make-temp-dir;
    my $file = make-temp-path;
    (my $other-file = $file.sibling: 'foo').open(:w).close;
    is $other-file, :e.Pair, 'derivative exists before DESTROY';
    $other-file.DESTROY;
    await Promise.in(1); # cause .DESTROY is async
    is $other-file, :e.Pair, 'derivative still exists after DESTROY';
}

group 'dir' => 2 => {
    my $dir = make-temp-dir;
    is $dir, :d .Pair, 'exists before DESTROY';
    $dir.DESTROY;
    await Promise.in(1); # cause .DESTROY is async
    is $dir, :!d.Pair, 'does not exist after DESTROY';
}

group 'dir, after changing path' => 2 => {
    temp $*TMPDIR = make-temp-dir;
    my $dir = make-temp-dir;
    (my $other-dir = $dir.sibling: 'foo').mkdir;
    is $other-dir, :d.Pair, 'derivative exists before DESTROY';
    $other-dir.DESTROY;
    await Promise.in(1); # cause .DESTROY is async
    is $other-dir, :d.Pair, 'derivative still exists after DESTROY';
}
