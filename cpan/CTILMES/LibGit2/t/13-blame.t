use Test;
use File::Temp;
use LibGit2;

plan 10;

my $testdir = tempdir;

isa-ok my $repo = Git::Repository.init($testdir),
    Git::Repository, 'init';

isa-ok my $commit-id = $repo.commit(:root, message => 'Initial root commit'),
    Git::Oid, 'commit';

$testdir.IO.child('afile').spurt(q:to/END/);
This is some content
for the file
so I can check out the blame.
END

lives-ok { $repo.index.add-all.write }, 'All added';

isa-ok $commit-id = $repo.commit(message => "Adding some files"),
    Git::Oid, 'commit';

isa-ok my $blame = $repo.blame-file('afile'), Git::Blame, 'blame-file';

is $blame.hunk-count, 1, 'hunk-count';

isa-ok my $hunk = $blame.hunk(0), Git::Blame::Hunk, 'hunk';

is $hunk.lines-in-hunk, 3, 'lines-in-hunk';

is $hunk.orig-path, 'afile', 'orig-path';

is $hunk.orig-start-line-number, 1, 'orig-start-line-number';

