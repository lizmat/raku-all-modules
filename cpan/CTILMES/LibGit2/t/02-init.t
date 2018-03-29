use Test;
use File::Temp;
use LibGit2;

plan 3;

my @gitfiles = <config description HEAD hooks info objects/info objects/pack
                refs/heads refs/tags>;

subtest 'simple',
{
    plan 2 + @gitfiles;
    my $testdir = tempdir;
    isa-ok my $repo = Git::Repository.init($testdir),
        Git::Repository, 'init';

    my $gitdir = $testdir.IO.child('.git');
    ok $gitdir.e, '.git exists';

    for @gitfiles { ok $gitdir.child($_).e, "$_ exists" }
}

subtest 'bare',
{
    plan 1 + @gitfiles;

    my $testdir = tempdir;

    isa-ok my $repo = Git::Repository.init($testdir, :bare),
        Git::Repository, 'init bare';

    for @gitfiles { ok $testdir.IO.child($_).e, "$_ exists" }
}

subtest 'options',
{
    plan 3 + @gitfiles;

    my $testdir = tempdir.IO.child('subdir');

    isa-ok my $repo = Git::Repository.init(~$testdir, :mkdir,
        description => 'my description'),
        Git::Repository, 'init options';

    my $gitdir = $testdir.IO.child('.git');
    ok $gitdir.e, '.git exists';

    for @gitfiles { ok $gitdir.IO.child($_).e, "$_ exists" }

    is $gitdir.child('description').slurp, 'my description', 'description';

}

done-testing;

