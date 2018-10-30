use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";

my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";
can-ok $p, 'List' or bail-out "{$p.^name} cannot .List";

subtest {
	my $list = <a b c d>;
	ok $list ~~ List, 'Data structure is a List';

	my $string = $p.dump: $list;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/List=(
	"a",
	"b",
	"c",
	"d"
)/;

	is $string, $expected, 'Dumping $list returns expected string';
	}, 'List in a var';

subtest {
	my $string = $p.dump: (2, 3, 4, 5);
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/List=(
	2,
	3,
	4,
	5
)/;
	is $string, $expected, 'Dumping $array works';
	}, 'List in arguments';


done-testing();
