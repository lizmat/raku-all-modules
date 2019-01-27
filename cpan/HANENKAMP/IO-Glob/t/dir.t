#!perl6

use v6;

use Test;
use IO::Glob;

{
    my @files = glob('t/fixtures/*.md').dir.sort;
    is @files.elems, 2;
    is @files[0], 't/fixtures/bar.md'.IO;
    is @files[1], 't/fixtures/foo.md'.IO;
}

{
    my @files = glob('fixtures/foo.*').dir('t').sort;
    is @files.elems, 2;
    is @files[0], "t/fixtures/foo.md".IO;
    is @files[1], "t/fixtures/foo.txt".IO;
}

{
    my @files = glob(*).dir("t/fixtures").sort;
    is @files.elems, 6;
    is @files[0], "t/fixtures/.".IO;
    is @files[1], "t/fixtures/..".IO;
    is @files[2], "t/fixtures/bar.md".IO;
    is @files[3], "t/fixtures/bar.txt".IO;
    is @files[4], "t/fixtures/foo.md".IO;
    is @files[5], "t/fixtures/foo.txt".IO;
}

{
    my @files = glob('t/fixtures/{foo,bar}.md').dir;
    is @files.elems, 2;
    is @files[0], 't/fixtures/foo.md'.IO;
    is @files[1], 't/fixtures/bar.md'.IO;
}

{
    my @files = glob('t/fixtures/{bar,foo}.md').dir;
    is @files.elems, 2;
    is @files[0], 't/fixtures/bar.md'.IO;
    is @files[1], 't/fixtures/foo.md'.IO;
}

done-testing;
