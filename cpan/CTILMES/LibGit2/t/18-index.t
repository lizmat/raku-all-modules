use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 10;

my $remote = 'https://github.com/CurtTilmes/test-repo.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote, $repodir), 'clone';

ok my $index = $repo.index, 'index';

is $index.entrycount, 2, 'entrycount';

ok my $entry = $index.get-bypath('README.md', 0), 'get-bypath';

is $entry.file-size, 11, 'file-size';
is $entry.path, 'README.md', 'path';
is $entry.id, '639f958ef57a5e0f4aca622f068e734354e2dd2e', 'id';

subtest 'Memory', {
    ok my $index = Git::Index.new, 'new';

    ok $index.version, 'version';

    lives-ok { $index.set-version(3) }, 'set-version';

    is $index.checksum, '0000000000000000000000000000000000000000', 'checksum';

    is $index.entrycount, 0, 'entrycount';

    throws-like { $index.read }, X::Git, 'Read in-memory fails',
        code => GIT_ERROR, message => /:s index is in'-'memory only/;

    throws-like { $index.write }, X::Git, 'Write in-memory fails',
        code => GIT_ERROR, message => /:s index is in'-'memory only/;
}

subtest 'Repo', {
    ok my $index = $repo.index, 'index';

    lives-ok { $index.read }, 'read';

    lives-ok { $index.write }, 'write';
}

subtest 'By File', {
    ok my $index = Git::Index.open("$repodir/.git/index"), 'open';

    lives-ok { $index.read }, 'read';

    lives-ok { $index.write }, 'write';

	is $index.entrycount, 2, 'entrycount';

	ok my $entry = $index.get-bypath('README.md', 0), 'get-bypath';

	is $entry.file-size, 11, 'file-size';
	is $entry.path, 'README.md', 'path';
	is $entry.id, '639f958ef57a5e0f4aca622f068e734354e2dd2e', 'id';
}

