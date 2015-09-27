use v6;
use Test;

use UNIX::Privileges;

plan 10;

if +$*USER != 0 {
	skip 'these tests must be run as root', 10;
	exit;
}

my $nobody;

try {
	$nobody = UNIX::Privileges::userinfo("nobody");
}

if $! {
	skip 'these tests require a user named "nobody"', 10;
	exit;
}

my $file1 = "02-root-a";
my $file2 = "02-root-b";
unlink($file1, $file2);

spurt("$file1", "did gyre and gimble in the wabe\n");
spurt("$file2", "did gyre and gimble in the wabe\n");

my ($ch1, $ch2);
lives-ok { $ch1 = UNIX::Privileges::chown("nobody", $file1) },
	'chown lived';
lives-ok { $ch2 = UNIX::Privileges::chown($nobody, $file2) },
	'chown lived';

ok $ch1, 'chown succeeded';
ok $ch2, 'chown succeeded';

my $root = UNIX::Privileges::userinfo("root");
lives-ok { UNIX::Privileges::chown("root", $file1) },
	'chown back to root lived';
lives-ok { UNIX::Privileges::chown($root, $file2) },
	'chown back to root lived';

my $dp;
lives-ok { $dp = UNIX::Privileges::drop($nobody); }, 'drop privileges lived';

ok $dp, 'drop privileges succeeded';


if "$file1".IO.e {
	dies-ok { spurt($file1, "blah\n") }, 'cannot write to file owned by root';
}

if "$file2".IO.e {
	dies-ok { spurt($file2, "blah\n") }, 'cannot write to file owned by root';
}

# vim: ft=perl6
