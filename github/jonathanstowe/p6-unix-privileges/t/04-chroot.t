use v6;
use Test;

use UNIX::Privileges;

plan 3;

if +$*USER != 0 {
    skip 'these tests must be run as root', 3;
	exit;
}

my $ch;
lives-ok { $ch = UNIX::Privileges::chroot("/tmp") }, 'chroot lived';
ok $ch, 'chroot succeeded';

is $*CWD, "/", 'chroot changed path to new root';

# vim: ft=perl6
