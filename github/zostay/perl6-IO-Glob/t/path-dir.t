#!perl6

use v6;

use Test;
use IO::Glob;

{
    my @files = "t/fixtures".IO.dir(test => glob('*.md')).sort;
    is @files.elems, 2;
    is @files[0], "t/fixtures/bar.md".IO;
    is @files[1], "t/fixtures/foo.md".IO;
}

{
    my @files = "t/fixtures".IO.dir(test => glob('foo.*')).sort;
    is @files.elems, 2;
    is @files[0], "t/fixtures/foo.md".IO;
    is @files[1], "t/fixtures/foo.txt".IO;
}

{
    my @files = "t/fixtures".IO.dir(test => glob(*)).sort;
    is @files.elems, 6;
    is @files[0], "t/fixtures/.".IO;
    is @files[1], "t/fixtures/..".IO;
    is @files[2], "t/fixtures/bar.md".IO;
    is @files[3], "t/fixtures/bar.txt".IO;
    is @files[4], "t/fixtures/foo.md".IO;
    is @files[5], "t/fixtures/foo.txt".IO;
}

done-testing;
