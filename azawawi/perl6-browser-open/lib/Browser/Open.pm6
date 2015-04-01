module Browser::Open;

use NativeCall;

my @known_commands =
(
	['', %*ENV<BROWSER>],
	['darwin',  '/usr/bin/open', 1],
	['solaris', 'xdg-open'],
	['solaris', 'firefox'],
	['linux',   'sensible-browser'],
	['linux',   'xdg-open'],
	['linux',   'x-www-browser'],
	['linux',   'www-browser'],
	['linux',   'htmlview'],
	['linux',   'gnome-open'],
	['linux',   'gnome-moz-remote'],
	['linux',   'kfmclient'],
	['linux',   'exo-open'],
	['linux',   'firefox'],
	['linux',   'seamonkey'],
	['linux',   'opera'],
	['linux',   'mozilla'],
	['linux',   'iceweasel'],
	['linux',   'netscape'],
	['linux',   'galeon'],
	['linux',   'opera'],
	['linux',   'w3m'],
	['linux',   'lynx'],
	['freebsd', 'xdg-open'],
	['freebsd', 'gnome-open'],
	['freebsd', 'gnome-moz-remote'],
	['freebsd', 'kfmclient'],
	['freebsd', 'exo-open'],
	['freebsd', 'firefox'],
	['freebsd', 'seamonkey'],
	['freebsd', 'opera'],
	['freebsd', 'mozilla'],
	['freebsd', 'netscape'],
	['freebsd', 'galeon'],
	['freebsd', 'opera'],
	['freebsd', 'w3m'],
	['freebsd', 'lynx'],
	['',        'open'],
);

sub open_browser(Str $url, Bool $all = False) is export
{
	if $*KERNEL.name eq 'win32'
	{
		# HINSTANCE ShellExecute(
		#  _In_opt_  HWND hwnd,
		#  _In_opt_  LPCTSTR lpOperation,
		#  _In_      LPCTSTR lpFile,
		#  _In_opt_  LPCTSTR lpParameters,
		#  _In_opt_  LPCTSTR lpDirectory,
		#  _In_      INT nShowCmd
		# );
		#
		sub ShellExecuteA(
			int32 $hwnd,
			Str $operation,
			Str $file,
			Str $parameters,
			Str $directory,
			int32 $show_cmd
		) returns int32 is native('shell32') { * }

		ShellExecuteA(0, "open", $url, "", "", 1);
	} else {
		my $cmd = $all ?? (open_browser_cmd_all) !! (open_browser_cmd);
		return unless $cmd;

		my $proc = Proc::Async.new($cmd, $url);
		$proc.start;
	}

	return;
}
 
sub open_browser_cmd is export returns Str
{
	return _check_all_cmds($*KERNEL.name);
}
 
sub open_browser_cmd_all is export returns Str {
	return _check_all_cmds('');
}
 
sub _check_all_cmds(Str $filter) returns Str
{
	for @known_commands -> $spec
	{
		my ($osname, $cmd, $exact, $no_search) = @$spec;
		next unless $cmd;
		next if $osname && $filter && $osname ne $filter;
		next if $no_search && !$filter && $osname ne $*KERNEL.name;

		return $cmd if $exact && $cmd.IO ~~ :x;
		return $cmd if $no_search;
		$cmd = _search_in_path($cmd);
		return $cmd if $cmd;
	}

	return;
}
 
sub _search_in_path(Str $cmd) returns Str
{
	# TODO use File::Which once it is ported
	my @paths = $*KERNEL.name eq 'win32'
		?? %*ENV<Path>.split(';')
		!! %*ENV<PATH>.split(':');
	for @paths -> $path
	{
		next unless $path;
		my Str $file = $*SPEC.catdir($path, $cmd);
		return $file if $file.IO ~~ :x;
	}

	return;
}
 
