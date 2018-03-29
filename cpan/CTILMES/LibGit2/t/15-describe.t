use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 4;

my $remote = 'https://github.com/CurtTilmes/test-repo.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote, $repodir), 'clone';

my $oid-str = 'd53bb27c0ecc26378aee6c9999012b144eba0c04';

my $oid = Git::Oid.new($oid-str);

my $commit = $repo.commit-lookup($oid);

ok my $describe = $commit.describe, 'describe';

is $describe.format, '0.2', 'describe format';

is $describe.format(:always-use-long-format), '0.2-0-gd53bb27', 'long format';

