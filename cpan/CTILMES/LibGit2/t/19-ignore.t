use Test;
use File::Temp;
use LibGit2;

plan 6;

my $repodir = tempdir;

ok my $repo = Git::Repository.init($repodir), 'init';

is $repo.is-ignored('foo.c'), False, 'foo.c not ignored';

lives-ok { $repo.ignore-add('*.c') }, 'ignore-add *.c';

is $repo.is-ignored('foo.c'), True, 'foo.c now ignored';

lives-ok { $repo.ignore-clear }, 'clear ignore';

is $repo.is-ignored('foo.c'), False, 'Not ignored';

