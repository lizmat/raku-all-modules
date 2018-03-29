use Test;
use File::Temp;
use LibGit2;

plan 6;

my $testdir = tempdir;

isa-ok my $repo = Git::Repository.init($testdir), Git::Repository, 'init';

isa-ok my $commit-id = $repo.commit(:root, message => 'Initial root commit'),
    Git::Oid, 'commit';

isa-ok $repo.commit-lookup($commit-id), Git::Commit, 'lookup commit';

for <a b c>
{
    $testdir.IO.child("{$_}file").spurt("This is some content for file $_.\n");
}

lives-ok { $repo.index.add-all.write }, 'All added';

isa-ok $commit-id = $repo.commit(message => "Adding some files"),
    Git::Oid, 'commit';

isa-ok $repo.commit-lookup($commit-id), Git::Commit, 'lookup commit';
