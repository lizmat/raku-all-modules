use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";

my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";
can-ok $p, 'Match' or bail-out "{$p.^name} cannot .Match";

subtest {
	my $fat-rat = FatRat.new: 1, 137;
	ok $fat-rat ~~ FatRat, 'Data structure is a FatRat';

	my $string = $p.dump: $fat-rat;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q{<1/137>};

	is $string, $expected, 'Dumping FatRat returns expected string';
	}, 'FatRat';

subtest {
	my $rat = <1/137>;
	ok $rat ~~ Rat, 'Data structure is a Rat';

	my $string = $p.dump: $rat;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q{<1/137>};

	is $string, $expected, 'Dumping Rat returns expected string';
	}, 'Rat';

subtest {
	my $rat = 1.234;
	ok $rat ~~ Rat, 'Data structure is a Rat';

	my $string = $p.dump: $rat;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q{<617/500>};

	is $string, $expected, 'Dumping Decimal returns expected string';
	}, 'Rat Decimal';

done-testing();
