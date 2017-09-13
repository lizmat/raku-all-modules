use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);

subtest {
	can-ok $class, 'new'            or bail-out "{package-name} cannot .new";
	can-ok $class, 'dump'           or bail-out "{package-name} cannot .dump";
	}, "{package-name} setup";


subtest {
	my $pretty = PrettyDump.new;
	isa-ok $pretty, $class;

	my Int $a = 137;

	{
	my $str = $pretty.dump: $a;
	is $str, $a;
	}

	{
	my $b = $a but role {
		method PrettyDump ( PrettyDump $pretty, Int:D :$depth = 0 ) {
			"({self.^name}) {self}";
			}
		};

	my $str = $pretty.dump: $b;
	like $str, rx/ ^^ '(Int+{' /, 'Role has anon class at start';
	}
	}, 'With role';

done-testing();
