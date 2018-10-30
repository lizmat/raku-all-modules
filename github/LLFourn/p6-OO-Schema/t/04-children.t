use Test;
use lib $?FILE.IO.parent.child("lib01").Str;

plan 4;

{
    use OS::Userland;
    ok Userland.children ~~ set(Windows,POSIX),".children";
    ok Userland.children(:all) ~~ set(
        Windows,
        XP,
        WindowsServer,
        POSIX,
        BSD,
        FreeBSD,
        OpenBSD,
        OSX,
        GNU,
        Debian,
        Ubuntu,
        RHEL,
        Fedora,
        CentOS,
    ),".children(:all)";
    ok GNU.children ~~ set(Debian,RHEL),"GNU.children";
    ok GNU.children(:all) ~~ set(
        Debian,
        Ubuntu,
        RHEL,
        Fedora,
        CentOS,
    ),"GNU.children(:all)";
}
