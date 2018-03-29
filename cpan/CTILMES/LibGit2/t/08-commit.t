use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 18;

my $remote = 'https://github.com/CurtTilmes/test-repo.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote, $repodir), 'clone';

ok my $oid = Git::Oid.new('d53bb27c0ecc26378aee6c9999012b144eba0c04'),
	'create oid';

ok my $commit = $repo.commit-lookup($oid), 'commit-lookup';

ok my $author = $commit.author, 'author';

is $author.name, 'Curt Tilmes', 'author name';
is $author.email, 'curt@tilmes.org', 'author email';
is $author.when, DateTime.new('2018-02-09T18:07:07-05:00'), 'author when';

ok my $committer = $commit.committer, 'committer';

is $committer.name, 'GitHub', 'committer name';
is $committer.email, 'noreply@github.com', 'committer email';

is $commit.type, GIT_OBJ_COMMIT, 'commit type';

is $commit.type-string, 'commit', 'commit type string';

is $commit.summary, 'Initial commit', 'summary';

is $commit.message, 'Initial commit', 'message';

is $commit.encoding, Str, 'encoding not specified';

is $commit.time, DateTime.new('2018-02-09T18:07:07-05:00'), 'time';

is $commit.tree-id, '75d09448ab10ddc2051b955474ac4db5f757dbbd', 'tree-id';

is $commit.parentcount, 0, 'no parent';
