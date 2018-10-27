use v6;
use Test;

plan 3;

# the other test files drop privs so we end up not being able to remove these

my @junk = '02-root-a', '02-root-b', '03-drop-str';

for @junk {
	unlink($_);
}

for @junk {
	nok $_.IO.e, "junk file $_ was removed";
}

# vim: ft=perl6
