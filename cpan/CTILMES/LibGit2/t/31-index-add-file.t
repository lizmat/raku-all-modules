use Test;
use File::Temp;
use LibGit2;

plan 14;

my $testdir = tempdir;

my $repo = Git::Repository.init($testdir);

is $repo.status-file('afile'), Nil, 'afile not present';

$testdir.IO.child('afile').spurt("This is some content for a file.\n");

isa-ok my $status = $repo.status-file('afile'), Git::Status::File, 'status-file';

is $status.is-workdir-new, True, 'is-workdir-new';
is $status.is-index-new, False, 'is-index-new';

isa-ok my $index = $repo.index, Git::Index, 'index';

lives-ok { $index.add-bypath('afile') }, 'add-bypath';

isa-ok $status = $repo.status-file('afile'), Git::Status::File, 'status-file';

is $status.is-workdir-new, False, 'is-workdir-new';
is $status.is-index-new, True, 'is-index-new';

lives-ok { $index.remove-bypath('afile') }, 'remove-bypath';

isa-ok $status = $repo.status-file('afile'), Git::Status::File, 'status-file';

is $status.is-workdir-new, True, 'is-workdir-new';
is $status.is-index-new, False, 'is-index-new';

lives-ok { $index.write }, 'write';
