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
$repo.commit(message => 'Add afile');

$repo.index.add-bypath('bfile').write;

isa-ok my $status = $repo.status-file('afile'), Git::Status::File,
	'status-file afile';

is $status.is-current, True, 'is-current';
is $status.is-ignored, False, 'is not ignored';
is $status.is-conflicted, False, 'is not conflicted';

isa-ok $status = $repo.status-file('bfile'), Git::Status::File,
	'status-file bfile';

is $status.is-current, False, 'is not current';
is $status.is-index-new, True, 'is index new';
is $status.is-workdir-new, False, 'is not workdir new';

isa-ok $status = $repo.status-file('cfile'), Git::Status::File,
	'status-file cfile';

is $status.is-current, False, 'is not current';
is $status.is-index-new, False, 'is not index new';
is $status.is-workdir-new, True, 'is workdir new';

for $repo.status-each
{
    ok .path ~~ /(b|c) file/, 'path';
}
