use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 11;

my $remote = 'https://github.com/CurtTilmes/test-repo.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote, $repodir), 'clone';

ok my $ref = $repo.reference-lookup('refs/heads/master'), 'reference master';

is $ref.is-branch, True, 'is-branch';

is $ref.is-tag, False, 'is-tag';

is $ref.is-note, False, 'is-note';

is $ref.is-remote, False, 'is-remote';

ok $ref = $repo.ref('master'), 'ref master';

is $ref.is-branch, True, 'is-branch';

ok (my @list = $repo.reference-list()), 'reference-list';

is-deeply $repo.references.map({.name}).sort,
	<refs/heads/master refs/remotes/origin/master refs/tags/0.1 refs/tags/0.2>,
	'references names';

is-deeply $repo.references.map({.short}).sort,
	('0.1', '0.2', 'master', 'origin/master'),
	'references short names';

