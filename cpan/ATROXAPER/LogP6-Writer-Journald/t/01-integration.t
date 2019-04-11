use Test;
use NativeCall;
use lib 'lib';
use LogP6::Writer::Journald;

plan 35;

sub systemd-exists() {
	return False if $*DISTRO.is-win;
	sub print(int32, Str --> int32)
		is native('systemd')
		is symbol('sd_journal_print') { * }
	try print(4, 'log-p6-writer-systemd-test');
	return True without $!;
	return False;
}

unless systemd-exists() {
	skip-rest('did not find "systemd" library. install libsystemd-dev (Ubuntu)');
	done-testing;
	exit;
}

my LogP6::Writer::Journald::Systemd::Native $systemd .= new;
my $args = ['MESSAGE=log-p6-writer-systemd-test', 'PRIORITY=4'];
$args.push("PARAM_$_=value_$_") for 1..33;

for 0..^$args.elems -> $elems {
	lives-ok { $systemd.send(|$args[0..$elems]) }, "send with $elems elems";
}

done-testing;
