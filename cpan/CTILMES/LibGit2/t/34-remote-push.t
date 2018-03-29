use Test;
use Test::When <author>;
use File::Temp;
use LibGit2;
use NativeCall;

my $remote-url = 'git@github.com:CurtTilmes/test-push.git';

my $repodir = tempdir;

my $cred = Git::Cred.ssh-key-from-agent('git');

ok my $repo = Git::Repository.clone($remote-url, $repodir, :$cred, :safe),
    'clone';

"$repodir/Changes".IO.spurt(DateTime.now ~ "\n" , :append);

lives-ok { $repo.index.add-all.write }, 'All added';

isa-ok $repo.commit(message => "Updated Changes"), Git::Oid, 'commit';

isa-ok my $remote = $repo.remote-lookup('origin'),
    'Git::Remote', 'remote-lookup';

is $remote.url, $remote-url, 'url';

lives-ok { $remote.push(:$cred) }, 'push';
