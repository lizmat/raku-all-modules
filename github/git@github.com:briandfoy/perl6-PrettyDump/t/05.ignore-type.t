use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);

subtest {
	can-ok $class, 'new'            or bail-out "{package-name} cannot .new";
	can-ok $class, 'dump'           or bail-out "{package-name} cannot .dump";
	can-ok $class, 'add-handler'    or bail-out "{package-name} cannot .add-handler";
	can-ok $class, 'ignore-type'    or bail-out "{package-name} cannot .ignore-type";
	}, "{package-name} setup";

subtest {
	my $pretty = PrettyDump.new;
	$pretty.add-handler: 'Hash',
		-> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str { Str:U };
	isa-ok $pretty, $class;

	my $ds = { Hamadryas => 'perlicus' };

	my $str = $pretty.dump: $ds;
	is $str, Str:U, 'Hash is excluded';
	}, 'Excluding Hash with handler';

subtest {
	my $pretty = PrettyDump.new;
	$pretty.add-handler: 'Hash',
		-> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str { Str:U };
	isa-ok $pretty, $class;

	my $ds = [ 'a', 'b', { Hamadryas => 'perlicus' }, 'c' ];

	my $str = $pretty.dump: $ds;
	is $str, qq/Array=[\n\t"a",\n\t"b",\n\t"c"\n]/, 'Hash is excluded';
	}, 'Excluding Hash in Array with handler';

subtest {
	my $pretty = PrettyDump.new;
	$pretty.add-handler: 'Hash',
		-> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str { Str:U };
	isa-ok $pretty, $class;

	my $ds = [ 'a', 'b', { Hamadryas => 'perlicus' }, 'c' ];

	my $str = $pretty.dump: $ds;
	is $str, qq/Array=[\n\t"a",\n\t"b",\n\t"c"\n]/, 'Hash is excluded';
	}, 'Excluding Hash with ignore-type';

done-testing();
