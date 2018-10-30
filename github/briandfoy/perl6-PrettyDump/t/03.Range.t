use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";

my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";
can-ok $p, 'Range' or bail-out "{$p.^name} cannot .Range";

subtest {
	my $range = 130..137;
	ok $range ~~ Range, 'Data structure is a Range';

	my $string = $p.dump: $range;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/130..137/;

	is $string, $expected, 'Dumping $range returns expected string';
	}, 'Inclusive range';

subtest {
	my $range = 130^..137;
	ok $range ~~ Range, 'Data structure is a Range';

	my $string = $p.dump: $range;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/130^..137/;

	is $string, $expected, 'Dumping $range returns expected string';
	}, 'Exclusive min range';

subtest {
	my $range = 130..^137;
	ok $range ~~ Range, 'Data structure is a Range';

	my $string = $p.dump: $range;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/130..^137/;

	is $string, $expected, 'Dumping $range returns expected string';
	}, 'Exclusive max range';

subtest {
	my $range = 130^..^137;
	ok $range ~~ Range, 'Data structure is a Range';

	my $string = $p.dump: $range;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/130^..^137/;

	is $string, $expected, 'Dumping $range returns expected string';
	}, 'Exclusive min-max range';

subtest {
	my $range = 0..*;
	ok $range ~~ Range, 'Data structure is a Range';

	my $string = $p.dump: $range;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/0..*/;

	is $string, $expected, 'Dumping $range returns expected string';
	}, 'Exclusive min-max range';


done-testing();
