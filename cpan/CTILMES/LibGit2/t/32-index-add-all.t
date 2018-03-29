use Test;
use File::Temp;
use LibGit2;

plan 9;

my $testdir = tempdir;

my $repo = Git::Repository.init($testdir);

for <a b c>
{
    $testdir.IO.child("{$_}file").spurt("This is some content for file $_.\n");
}

is set($repo.status-each.map({ .path if .is-workdir-new })),
   set(<afile bfile cfile>), 'workdir added';

is set($repo.status-each.map({ .path if .is-index-new })),
   set(), 'index added';

isa-ok my $index = $repo.index, Git::Index, 'index';

lives-ok { $index.add-all }, 'All added';

is set($repo.status-each.map({ .path if .is-workdir-new })),
   set(), 'workdir added';

is set($repo.status-each.map({ .path if .is-index-new })),
   set(<afile bfile cfile>), 'index added';

lives-ok { $index.remove-all("bfile") }, 'bfile removed';

is set($repo.status-each.map({ .path if .is-workdir-new })),
   set(<bfile>), 'workdir added';

is set($repo.status-each.map({ .path if .is-index-new })),
   set(<afile cfile>), 'index added';
