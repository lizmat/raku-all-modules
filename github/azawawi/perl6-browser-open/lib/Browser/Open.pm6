unit module Browser::Open;

use NativeCall;
use File::Which;

my @known-commands =
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

sub open-browser(Str $url, Bool $all = False) is export
{
    if $*KERNEL.name eq 'win32'
    {
        #
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
        my $cmd = $all ?? (open-browser-cmd-all) !! (open-browser-cmd);
        return unless $cmd;

        my $proc = Proc::Async.new($cmd, $url);
        $proc.start;
    }

    return;
}
 
sub open-browser-cmd is export returns Str
{
    return _check-all-cmds($*KERNEL.name);
}
 
sub open-browser-cmd-all is export returns Str {
    return _check-all-cmds('');
}
 
sub _check-all-cmds(Str $filter) returns Str
{
    for @known-commands -> $spec
    {
        my ($osname, $cmd, $exact, $no_search) = @$spec;
        next unless $cmd;
        next if $osname && $filter && $osname ne $filter;
        next if $no_search && !$filter && $osname ne $*KERNEL.name;

        return $cmd if $exact && $cmd.IO ~~ :x;
        return $cmd if $no_search;
        $cmd = which($cmd);
        return $cmd if $cmd;
    }

    return;
}
