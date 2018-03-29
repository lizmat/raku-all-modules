use Test;
use File::Temp;
use LibGit2;

plan 9;

my $testdir = tempdir;

Git::Repository.init($testdir);

isa-ok my $repo = Git::Repository.open($testdir), Git::Repository, 'open';

is $repo.is-empty, True, 'is empty';

is $repo.is-bare, False, 'is not bare';

is $repo.is-shallow, False, 'is shallow';

isa-ok $repo = Git::Repository.open(~$testdir.IO.child('.git'), :bare),
    Git::Repository, 'open bare';

is $repo.is-bare, True, 'is bare';

my $subdir = $testdir.IO.child('a/b/c').mkdir;

isa-ok $repo = Git::Repository.open(~$subdir, :search),
    Git::Repository, 'open search';

is $repo.commondir, $testdir.IO.child('.git/'), 'correct git dir';

is $repo.item-path('index'), $testdir.IO.child('.git/index'), 'item-path';

