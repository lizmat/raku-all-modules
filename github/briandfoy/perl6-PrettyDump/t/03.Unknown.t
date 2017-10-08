use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";
my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";


#`(
This class should not respond to .Str or .PrettyDump. The easiest
way to do that is to fake that they can't do anything is to have
.can always return False
)
class TinyClass {
	has $.foo;
	method can ( Str $method ) { False }
	}


my $tiny-class-str = 'TinyClass';
my $tiny-class = ::($tiny-class-str);

is $class.can( $tiny-class-str ).elems, 0, "{package-name} does not handle $tiny-class-str";

can-ok $tiny-class, 'can';
is $tiny-class.can( 'Str' ), False, "$tiny-class-str does not do .Str";
is $tiny-class.can( 'PrettyDump' ), False, "$tiny-class-str does not do .PrettyDump";

subtest {
	my $object = $tiny-class.new;
	isa-ok $object, $tiny-class;

	my $string = $p.dump: $object;
	isa-ok $string, Str, 'Got Str back';
	my $expected = qq/(Unhandled {$tiny-class-str})/;

	is $string, $expected, 'Dumping @array returns expected string';
	}, 'Object with no .Str or .PrettyDump';

done-testing();
