use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 23;

my $remote-url = 'https://github.com/CurtTilmes/test-repo.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote-url, $repodir), 'clone';

isa-ok my $remote = $repo.remote-lookup('origin'),
    'Git::Remote', 'remote-lookup';

is $remote.name, 'origin', 'name';

is $remote.url, $remote-url, 'url';

isa-ok $remote.autotag, Git::Remote::Autotag::Option, 'autotag';

lives-ok { $remote.connect(dir => 'fetch') }, 'remote connect';

is $remote.connected, True, 'connected';

is $remote.default-branch, 'refs/heads/master', 'default-branch';

is-deeply $remote.ls.map({.name}).sort,
	('HEAD', 'refs/heads/master', 'refs/tags/0.1', 'refs/tags/0.2',
		'refs/tags/0.2^{}'),
	'remote ls';

lives-ok { $remote.download }, 'download';

lives-ok { $remote.disconnect }, 'remote disconnect';

is $remote.connected, False, 'disconnected';

is $remote.get-fetch-refspecs, <+refs/heads/*:refs/remotes/origin/*>,
    'get-fetch-refspecs';

for $remote.refspecs
{
    is $_, '+refs/heads/*:refs/remotes/origin/*', 'Str';
    is .direction, 'fetch', 'direction';
    is .dst, 'refs/remotes/origin/*', 'dst';
    is .dst-matches('refs/remotes/origin/master'), True, 'dst-matches';
    is .force, True, 'force';
    is .rtransform('refs/remotes/origin/master'), 'refs/heads/master',
        'rtransform';
    is .src, 'refs/heads/*', 'src';
    is .src-matches('refs/heads/master'), True, 'src-matches';
    is .transform('refs/heads/master'), 'refs/remotes/origin/master',
        'transform';
}

lives-ok { $remote.fetch }, 'fetch';
