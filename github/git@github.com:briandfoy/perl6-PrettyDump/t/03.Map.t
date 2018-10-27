use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";

my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";
can-ok $p, 'Map' or bail-out "{$p.^name} cannot .Map";

subtest {
	my $map = Map.new: ( a => 'b', c => 'd' );
	ok $map ~~ Map, 'Data structure is an Map';

	my $string = $p.dump: $map;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/Map=(
	:a("b"),
	:c("d")
)/;
	is $string, $expected, 'Dumping $map works';
	}, '$map';

done-testing();
