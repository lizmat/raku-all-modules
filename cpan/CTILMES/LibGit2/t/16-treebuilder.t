use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 4;

my $remote = 'https://github.com/CurtTilmes/test-repo.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote, $repodir), 'clone';

ok my $builder = $repo.treebuilder, 'treebuilder';

is $builder.entrycount, 0, 'entrycount';

lives-ok { $builder.clear }, 'clear';
