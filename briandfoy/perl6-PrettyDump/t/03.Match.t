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
	'abcdef' ~~ / cd /;
	ok $/ ~~ Match, 'Data structure is a Match';

	my $string = $p.dump: $/;
	isa-ok $string, Str, 'Got Str back';
	my $expected = Q/Match=(
	:from(2),
	:hash(Map=()),
	:list(List=()),
	:made(Mu),
	:orig("abcdef"),
	:pos(4),
	:to(4)
)/;

	is $string, $expected, 'Dumping Match works';
	}, 'Match';

done-testing();
