use Test;
use File::Temp;
use LibGit2;

plan 4;

my $testdir = tempdir;

isa-ok my $repo = Git::Repository.init($testdir), Git::Repository, 'init';

$repo.commit(:root, message => 'Initial root commit');

my $afile = $testdir.IO.child("afile");
$afile.spurt("This is some content for file afile.\n");

$repo.index.add-bypath('afile').write;
$repo.commit(message => 'adding afile');

$afile.spurt("This is a change for file afile.\n");

is $afile.slurp, "This is a change for file afile.\n", 'changed';

lives-ok { $repo.checkout(:head, :force) }, 'checkout HEAD original';

is $afile.slurp, "This is some content for file afile.\n", 'original content';
