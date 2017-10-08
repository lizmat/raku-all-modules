use v6;
use Test;
use File::Find::Duplicates;

plan 7;

sub sort-arrays (@arr) {
    # 2 layer sort to ensure test sameness
    # though in practice, order is less important
    my @x = map *.sort, @arr;
    my @y = @x.sort(*.[0]);
}

sub find-sorted(|c) {
    my @found = find_duplicates(|c);
    @found = map *.sort, @found;
    @found.sort(*.[0]);
    #@found.map( *.sort).sort( *.[0] );
}


is find-sorted( dirs => ['t/test-files'] ),
    ( ["t/test-files/empty1", "t/test-files/empty2"],
    ["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"]),
    "Basic functionality";

is find-sorted( dirs => ['t/test-files'], recursive => True ),
    ( ["t/test-files/empty1", "t/test-files/empty2"],
     ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
     ["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"]),
    "Recursive search";

is find-sorted( dirs => ['t/test-files'], ignore_empty => True ),
    (["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"],),
    "Ignoring empty files";

is find-sorted( dirs => ['t/test-files'], recursive => True, method=> 'compare'),
    (["t/test-files/empty1", "t/test-files/empty2"],
     ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
     ["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"]),
    "Byte comparisons";

is find-sorted( dirs => ['t/test-files/foo1', 't/test-files/foo2'],
                     ignore_empty => True ),
    (["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],),
    "Multiple directory search";

is sort-arrays('t/test-files'.IO.duplicates),
    (["t/test-files/empty1", "t/test-files/empty2"],
     ["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"]),
    "IO::Path Method";

is sort-arrays('t/test-files'.IO.duplicates(recursive => True, ignore_empty=>True)),
    (["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
     ["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"]),
    "Method with recursion";



