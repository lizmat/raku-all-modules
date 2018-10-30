use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";
my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";

class TinyClass is Hash {}

my $tiny-class-str = 'TinyClass';
my $tiny-class = ::($tiny-class-str);

my $parent-class-str = 'Hash';
my $parent-class = ::($parent-class-str);

is $class.can( $tiny-class-str ).elems, 0, "{package-name} does not handle $tiny-class-str";
isa-ok $tiny-class, $parent-class-str;
is $class.can( $parent-class-str ).Bool, True, "{package-name} handles $parent-class-str";

can-ok $tiny-class, 'can';
is $tiny-class.can( 'PrettyDump' ).elems, 0, "$tiny-class-str does not do .PrettyDump";

subtest {
	my $object = $tiny-class.new:  'abc', '123', 'xyz', 'def';
	isa-ok $object, $tiny-class;
	isa-ok $object, $parent-class;

	my $string = $p.dump: $object;
	isa-ok $string, Str, 'Got Str back';
	my $expected = qq/{$tiny-class-str}=(
	:abc("123"),
	:xyz("def")
)/;

	is $string, $expected, 'Dumping $object returns expected string';
	}, 'Object that inherits from Hash';

done-testing();
