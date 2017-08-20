use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);

subtest {
	can-ok $class, 'new'            or bail-out "{package-name} cannot .new";
	can-ok $class, 'add-handler'    or bail-out "{package-name} cannot .add-handler";
	can-ok $class, 'remove-handler' or bail-out "{package-name} cannot .remove-handler";
	can-ok $class, 'handles'        or bail-out "{package-name} cannot .handles";
	can-ok $class, 'dump'           or bail-out "{package-name} cannot .dump";
	}, "{package-name} setup";

class TinyClass {
	has $.foo;
	method can ( Str $method ) { False }
	}
my $tiny-class-str = 'TinyClass';
my $tiny-class = ::($tiny-class-str);

subtest {
	is $class.can( $tiny-class-str ).elems, 0, "{package-name} does not handle $tiny-class-str";

	can-ok $tiny-class, 'can';
	is $tiny-class.can( 'Str' ), False, "$tiny-class-str does not do .Str";
	is $tiny-class.can( 'PrettyDump' ), False, "$tiny-class-str does not do .PrettyDump";
	}, "$tiny-class-str setup";

subtest {
	my $p = $class.new;
	is $p.handles( $tiny-class-str ), False, "Basic object does not handle $tiny-class-str";
	my $sub = -> PrettyDump $p, $ds, Int:D :$depth=0 --> Str {
		'Hello foo ' ~ $ds.foo
		};
	$p.add-handler( $tiny-class-str, $sub );
	is $p.handles( $tiny-class-str ), True, "Now basic object handles $tiny-class-str";
	my $tiny-obj = $tiny-class.new: :foo(123);
	is $p.dump( $tiny-obj ), 'Hello foo 123', 'Dump returns the expected string';

	$p.remove-handler: $tiny-class-str;
	is $p.handles( $tiny-class-str ), False, "Basic object no longer handles $tiny-class-str";
	}, 'Try a handler with a good signature';

subtest {
	my $p = $class.new;
	is $p.handles( $tiny-class-str ), False, "Basic object does not handle $tiny-class-str";
	my $sub = -> { 'Hello foo ' };
	dies-ok { $p.add-handler( $tiny-class-str, $sub ) }, "Bad signature dies";
	}, 'Try a handler with a bad signature';

done-testing();
