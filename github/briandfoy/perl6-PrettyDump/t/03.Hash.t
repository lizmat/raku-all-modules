use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";

my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";
can-ok $p, 'Hash' or bail-out "{$p.^name} cannot .Hash";

subtest {
	my %hash = <a b c d>;
	ok %hash ~~ Hash, 'Data structure is a Hash';

	my $string = $p.dump: %hash;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/Hash={
	:a("b"),
	:c("d")
}/;

	is $string, $expected, 'Dumping %hash returns expected string';
	}, '%hash';

subtest {
	my $hash = %(<a b c d>);
	ok $hash ~~ Hash, 'Data structure is a Hash';

	my $string = $p.dump: $hash;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/Hash={
	:a("b"),
	:c("d")
}/;
	is $string, $expected, 'Dumping $hash returns expected string';
	}, '$hash';

subtest {
	my $string = $p.dump: %(<a b c d>);
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/Hash={
	:a("b"),
	:c("d")
}/;

	is $string, $expected, 'Dumping {} returns expected string';
	}, '{}';

done-testing();
