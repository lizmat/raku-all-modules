use v6;

use Test;
use IO::Glob;

{
    my @files = glob('t/deep-fixtures/*/*/foo.md').dir.sort;
    is @files.elems, 2;
    is @files[0], 't/deep-fixtures/a/a/foo.md'.IO;
    is @files[1], 't/deep-fixtures/c/c/foo.md'.IO;
}

{
    my @files = glob('t/deep-fixtures/*/*/bar.md').dir.sort;
    is @files.elems, 2;
    is @files[0], 't/deep-fixtures/a/a/bar.md'.IO;
    is @files[1], 't/deep-fixtures/b/a/bar.md'.IO;
}

done-testing;
