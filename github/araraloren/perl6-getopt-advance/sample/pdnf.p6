#!/usr/bin/env perl6

use Getopt::Advance;

my %cmd-map = %{
	ar => 'autoremove',
	ck => 'check',
	cu => 'check-update',
	cl => 'clean',
	dl => 'deplist',
	ds => 'distro-sync',
	dg => 'downgrade',
	gp => 'group',
	hp => 'help',
	hi => 'history',
	if => 'info',
	in => 'install',
	ls => 'list',
	mc => 'makecache',
	mr => 'mark',
	wp => 'provides',
	ri => 'reinstall',
	rm => 'remove',
	rl => 'repolist',
	rq => 'repoquery',
	se => 'search',
	up => 'upgrade',
	co => 'copr',
	do => 'download',
};
my $os = OptionSet.new;

$os.insert-cmd($_) for %cmd-map.keys;

await wrap-command(
	$os,
	"dnf",
	tweak => -> $os, $ret {
		for %cmd-map.kv -> $cmd, $map {
			if $os.get-cmd($cmd).success {
				$ret.noa.shift;
				$ret.noa.unshift($map);
				last;
			}
		}
	},
	:async
).start;
