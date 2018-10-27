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
This class should respond to .Str
)
class TinyClass {
	has $.foo = 10;
	method Str { "foo is ｢$.foo｣" }
	}


my $tiny-class-str = 'TinyClass';
my $tiny-class = ::($tiny-class-str);

is $class.can( $tiny-class-str ).elems, 0, "{package-name} does not handle $tiny-class-str";

can-ok $tiny-class, 'can';
is $tiny-class.can( 'Str' ).Bool, True, "$tiny-class-str does .Str";
is $tiny-class.can( 'PrettyDump' ).elems, 0, "$tiny-class-str does not do .PrettyDump";

subtest {
	my $object = $tiny-class.new: :foo(137);
	isa-ok $object, $tiny-class;

	my $string = $p.dump: $object;
	isa-ok $string, Str, 'Got Str back';
	my $expected = qq/($tiny-class-str): foo is ｢137｣/;

	is $string, $expected, 'Dumping $object returns expected string';
	}, 'Object with .Str';

done-testing();
