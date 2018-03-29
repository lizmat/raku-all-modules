use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 6;

my $remote = 'https://github.com/CurtTilmes/test-repo.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote, $repodir), 'clone';

ok (my @tag-list = $repo.tag-list), 'tag list';

like '0.1', /@tag-list/, 'tag 0.1 in tag list';

ok (@tag-list = $repo.tag-list('0*')), 'tag list match';

like '0.1', /@tag-list/, 'tag 0.1 in tag list';

ok my $id = $repo.name-to-id('refs/tags/0.1'), 'name-to-id';
