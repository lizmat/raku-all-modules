use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";

my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";
can-ok $p, 'Array' or bail-out "{$p.^name} cannot .Array";

subtest {
	my @array = <a b c d>;
	ok @array ~~ Array, 'Data structure is an array';

	my $string = $p.dump: @array;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/Array=[
	"a",
	"b",
	"c",
	"d"
]/;

	is $string, $expected, 'Dumping @array works';
	}, '@array';

subtest {
	my $array = [<a b c d>];
	ok $array ~~ Array, 'Data structure is an array';

	my $string = $p.dump: $array;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/Array=[
	"a",
	"b",
	"c",
	"d"
]/;
	is $string, $expected, 'Dumping $array works';
	}, '$array';

subtest {
	my $string = $p.dump: [<a b c d>];
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/Array=[
	"a",
	"b",
	"c",
	"d"
]/;

	is $string, $expected, 'Dumping [] array works';
	}, '[]';

done-testing();
