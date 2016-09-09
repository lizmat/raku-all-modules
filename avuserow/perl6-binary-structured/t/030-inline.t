use v6;
use lib 'lib';

use Test;

use Binary::Structured;

class InnerStruct is Binary::Structured {
	has int8 $.a is rw;
	has int8 $.b is rw;
}

class OuterStruct is Binary::Structured {
	has int8 $.before is rw;

	has InnerStruct $.inner is rw;

	has int8 $.after is rw;
}

subtest 'basic parse', {
	my $buf = Buf.new: 1, 2, 3, 4;
	my $parser = OuterStruct.new;
	$parser.parse($buf);

	is $parser.before, 1;
	is $parser.inner.a, 2;
	is $parser.inner.b, 3;
	is $parser.after, 4;
};

subtest 'basic build', {
	my $parser = OuterStruct.new;
	$parser.inner .= new;

	$parser.before = 1;
	$parser.inner.a = 2;
	$parser.inner.b = 3;
	$parser.after = 4;

	my $res = $parser.build;
	is $res, Buf.new(1, 2, 3, 4);
};

done-testing;
