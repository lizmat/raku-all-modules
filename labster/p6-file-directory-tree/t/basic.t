use Test;
use File::Directory::Tree;

plan 7;

ok (my $tmpdir = IO::Spec.tmpdir), "We can haz a tmpdir";
$tmpdir or skip_rest "for EPIC FAIL at finding a place to write";

my $tmppath = $tmpdir.path;
ok mktree($tmppath.child( 
    $*SPEC.catdir( "foo", "bar", $*SPEC.updir, "baz")).Str ), "mktree runs";
ok $tmppath.child("foo").d, '$TEMP/foo exists';
ok $tmppath.child('foo').dir.elems == 2, "mktree produces correct number of elements";
ok spurt("$tmpdir/foo/filetree.tmp", "temporary test file, delete after reading"), "created a test file";
say "# ", "$tmpdir/foo".path.dir;
ok rmtree($tmppath.child("foo")), "rmtree runs";
ok $tmppath.child("foo").e.not, "rmtree successfully deletes temp files";

done;
