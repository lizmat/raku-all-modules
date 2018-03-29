use Test;
use File::Temp;
use LibGit2;

plan 12;

my $testdir = tempdir;

isa-ok my $repo = Git::Repository.init($testdir), Git::Repository, 'init';

isa-ok my $commit-id = $repo.commit(:root, message => 'Initial root commit'),
    Git::Oid, 'commit';

is $repo.is-worktree, False, 'Main repo is not worktree';

isa-ok $repo.commit-lookup($commit-id), Git::Commit, 'lookup commit';

for <a b c>
{
    $testdir.IO.child("{$_}file").spurt("This is some content for file $_.\n");
}

lives-ok { $repo.index.add-all.write }, 'All added';

ok $repo.commit(message => "Adding some files"), 'commit';

my $tempdir = tempdir;

my $worktreedir = ~$tempdir.IO.child('worktree1');

ok $repo.worktree-add('worktree1', $worktreedir), 'worktree-add';

ok my $worktree = $repo.worktree-lookup('worktree1'), 'worktree-lookup';

ok $worktree.validate, 'worktree validate';

is $repo.head-for-worktree('worktree1').name, 'refs/heads/worktree1',
    'head-for-worktree';

isa-ok my $workrepo = Git::Repository.open($worktreedir),
    Git::Repository, 'open worktree as repository';

is $workrepo.is-worktree, True, 'Repo is worktree';
