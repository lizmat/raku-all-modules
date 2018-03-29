use Test;
use File::Temp;
use LibGit2;

plan 15;

my $testdir = tempdir;

isa-ok my $repo = Git::Repository.init($testdir), Git::Repository, 'init';

$repo.commit(:root, message => 'Initial root commit');

for <a b c>
{
    $testdir.IO.child("{$_}file").spurt("This is some content for file $_.\n");
}

$repo.index.add-bypath('afile').write;

isa-ok my $diff = $repo.diff-tree-to-index,
	Git::Diff, 'diff-index-to-workdir';

is $diff.elems, 1, '1 file added';

ok my $patches = $diff.patches, 'patches';

is $patches.elems, 1, '1 patch';

isa-ok my $patch = $diff.patch(0), Git::Patch, 'first patch';

is $patch, q:to/PATCH/, 'patch content';
	diff --git a/afile b/afile
	new file mode 100644
	index 0000000..5966fc3
	--- /dev/null
	+++ b/afile
	@@ -0,0 +1 @@
	+This is some content for file a.
	PATCH

is $patch.elems, 1, '1 hunks in patch';

for $patch.hunks
{
    is .elems, 1, '1 line in hunk';

    for .lines
    {
        is .num-lines, 1, '1 line changed';
        is .old-lineno, -1, 'no preveious line';
        is .new-lineno, 1, 'line 1 changed';
        is .content-len, 33, '33 chars changed';
        is .content-offset, 0, 'from 0';
        is .content, "This is some content for file a.\n", 'content';
    }
}
