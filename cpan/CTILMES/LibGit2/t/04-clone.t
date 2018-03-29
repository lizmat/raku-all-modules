use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 2;

my $remote = 'https://github.com/CurtTilmes/test-repo.git';

my @gitfiles = <config description HEAD hooks info objects/info objects/pack
                refs/heads refs/tags>;

subtest 'simple',
{
    plan 13;

    my $repodir = tempdir;

    ok my $repo = Git::Repository.clone($remote, $repodir), 'clone';

    ok my $gitdir = $repo.commondir.IO, 'commondir';

    for @gitfiles { ok $gitdir.child($_).e, "$_ exists" }

    for <LICENSE README.md> { ok $repodir.IO.child($_).e, "$_ exists" }
}

subtest 'bare',
{
    plan 10;

    my $gitdir = tempdir;

    ok my $repo = Git::Repository.clone($remote, $gitdir, :bare), 'clone';

    for @gitfiles { ok $gitdir.IO.child($_).e, "$_ exists" }

}

done-testing;
