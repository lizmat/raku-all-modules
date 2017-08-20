use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";

my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";
can-ok $p, 'Pair' or bail-out "{$p.^name} cannot .Array";

subtest {
	my $pair = Hamadryas => 'perlicus';
	ok $pair ~~ Pair, 'Data structure is a Pair';

	my $string = $p.dump: $pair;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/:Hamadryas("perlicus")/;

	is $string, $expected, 'Dumping @array works';
	}, 'Pair with arrow notation, in var';

subtest {
	my $pair = :Hamadryas('perlicus');
	ok $pair ~~ Pair, 'Data structure is a Pair';

	my $string = $p.dump: $pair;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/:Hamadryas("perlicus")/;

	is $string, $expected, 'Dumping colon Pair in var return expected string';
	}, 'Pair with colon notation, in var';

subtest {
	my $pair = Pair.new: 'Hamadryas', 'perlicus';
	ok $pair ~~ Pair, 'Data structure is a Pair';

	my $string = $p.dump: $pair;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/:Hamadryas("perlicus")/;

	is $string, $expected, 'Dumping constructor Pair in var return expected string';
	}, 'Pair with constructor, in var';

subtest {
	my $string = $p.dump: ('Hamadryas' => 'perlicus');
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/:Hamadryas("perlicus")/;

	is $string, $expected, 'Dumping arrow Pair in arguments return expected string';
	}, 'Pair with arrow notation, in arguments';

subtest {
	my $string = $p.dump: (:Hamadryas('perlicus'));
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/:Hamadryas("perlicus")/;

	is $string, $expected, 'Dumping colon Pair in arguments return expected string';
	}, 'Pair with colon notation, in arguments';

done-testing();
