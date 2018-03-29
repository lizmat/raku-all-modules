use Test;
use File::Temp;
use LibGit2;

plan 4;

my $testdir = tempdir;

isa-ok my $repo = Git::Repository.init($testdir), Git::Repository, 'init';

my $commit1 = $repo.commit(:root, message => 'Initial root commit');

for <a b c>
{
    $testdir.IO.child("{$_}file").spurt("This is some content for file $_.\n");
}

$repo.index.add-all.write;

my $commit2 = $repo.commit(message => 'Add some files');

isa-ok my $revwalk = $repo.revwalk.sorting(:time), Git::Revwalk, 'Revwalk';

my $seq = $revwalk.walk(push => 'HEAD', :simplify-first-parent);

is $seq[0], $commit2, 'commit 2';

is $seq[1], $commit1, 'commit 1';
