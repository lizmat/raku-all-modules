#!perl6

use v6;

use Test;
use IO::Glob;

{
    my @files = glob('t/fixtures/*.md').sort;
    is @files.elems, 2;
    is @files[0], 't/fixtures/bar.md'.IO;
    is @files[1], 't/fixtures/foo.md'.IO;
}

{
    todo 'expansion order should be respected', 3;
    my @files = glob('t/fixtures/{foo,bar}.md');
    is @files.elems, 2;
    is @files[0], 't/fixtures/foo.md'.IO;
    is @files[1], 't/fixtures/bar.md'.IO;
}

done-testing;
