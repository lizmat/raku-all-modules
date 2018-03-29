use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 6;

my $remote = 'https://github.com/CurtTilmes/test-repo.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote, $repodir), 'clone';

ok my $tree = $repo.revparse-single('HEAD^{tree}'), 'revparse-single tree';

my @files = <LICENSE README.md>;

for $tree.walk.list -> ($root, $entry)
{
	ok $entry.type == GIT_OBJ_BLOB, 'type Blob';
	ok $entry.name ~~ /@files/, "name - $entry.name()";
}
