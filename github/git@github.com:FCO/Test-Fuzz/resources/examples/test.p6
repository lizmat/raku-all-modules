use lib <lib ../../lib>;
use Test::Fuzz;

sub bla (Int $bla, Int $ble --> UInt) is fuzzed {
	$bla + $ble
}

sub ble (Int $ble) is fuzzed {
	die "it is prime!" if $ble.is-prime
}

sub bli (Int $bli) is fuzzed(:42returns, :test{.so}) {}

sub blo (UInt $blo) is fuzzed {
	return $blo
}

subset Prime of UInt where {not .defined or .is-prime};

sub blu (Prime $blu) is fuzzed({test => not *.is-prime}) {
	return $blu * $blu
}

sub pla ($value --> True) is fuzzed {}

multi MAIN(Bool :$fuzz!) {
	run-tests
}

multi MAIN(Str :$fuzz!) {
	my @funcs = $fuzz.split(/\s+/);
	run-tests @funcs
}

multi MAIN {
	say bla(1, 2);
	ble(4);
	bli(42);
	say blo(42);
}
