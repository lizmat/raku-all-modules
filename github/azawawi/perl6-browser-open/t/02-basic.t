use v6;
use Test;

use Browser::Open;

my $osname = $*VM.osname;
my $cmd    = open-browser-cmd;
if $cmd {
    ok $cmd, "got command '$cmd'";
    if $*DISTRO.is-win {
        skip("Will not test execution on MSWin32", 1) ;
    } else {
        ok $cmd.IO ~~ :e, '... and we can execute it';
    }
    diag "Found '$cmd' for '$osname'";
    ok open-browser-cmd-all, '... and the all commands version is also ok';
} else {
    if $*DISTRO.is-win {
        skip("Will not test open-browser-cmd on windows", 1) ;
    } else {
        if $cmd {
            pass "Found command in the 'all' version ($cmd)";
        }
        else {
            diag "Need more data for OS: $osname";
        }
    }
}

done-testing;
