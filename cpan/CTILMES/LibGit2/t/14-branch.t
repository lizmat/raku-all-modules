use Test;
use File::Temp;
use LibGit2;

plan 18;

my $testdir = tempdir;

ok my $repo = Git::Repository.init($testdir), 'init';

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

throws-like { $repo.reference-lookup('refs/heads/abranch') },
    X::Git, 'branch not found';

ok my $ref = $repo.branch-create('abranch', $commit-id, :set-head),
    'branch-create set-head';

is $ref.is-branch, True, 'branch is branch';
is $ref.is-head, True, 'branch is head';

is $ref.branch-name, 'abranch', 'branch-name';
is $ref.name, 'refs/heads/abranch', 'name';

is set($repo.branch-list».branch-name), set(<master abranch>), 'branch-list';

throws-like { $ref.branch-delete }, X::Git, 'cannot delete HEAD branch';

ok $repo.set-head('refs/heads/master'), 'set HEAD to master';

is $repo.head-detached, False, 'head-detached';

ok my $newref = $ref.branch-move('newbranch'), 'branch-move';

is set($repo.branch-list».branch-name), set(<master newbranch>), 'branch-list';

lives-ok { $newref.branch-delete }, 'ok to delete branch now';

