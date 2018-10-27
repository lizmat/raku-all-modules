use v6;
use lib 'lib';

use Test;

use Binary::Structured;

class InnerStruct is Binary::Structured {
	has uint8 $.a is rw;
	has uint8 $.b is rw;
}

class OuterStruct is Binary::Structured {
	has uint8 $.count is rw;

	has Array[InnerStruct] $.items is read(method {self.pull-elements($!count)}) is rw = Array[InnerStruct].new;

	has uint8 $.after is rw;
}

subtest 'no elements', {
	my $buf = Buf.new: 0, 4;
	my $parser = OuterStruct.new;
	$parser.parse($buf);

	is $parser.count, 0;
	is $parser.items.elems, 0;
	is $parser.after, 4;
};

subtest 'basic parse (count = 1)', {
	my $buf = Buf.new: 1, 2, 3, 4;
	my $parser = OuterStruct.new;
	$parser.parse($buf);

	is $parser.count, 1;
	is $parser.items[0].a, 2;
	is $parser.items[0].b, 3;
	is $parser.after, 4;
};

subtest 'basic parse (count = 2)', {
	my $buf = Buf.new: 2, 1, 10, 2, 20, 100;
	my $parser = OuterStruct.new;
	$parser.parse($buf);

	is $parser.count, 2;
	is $parser.items.elems, 2;
	is $parser.items[0].a, 1;
	is $parser.items[0].b, 10;
	is $parser.items[1].a, 2;
	is $parser.items[1].b, 20;
	is $parser.after, 100;
};

subtest 'basic build (count = 0)', {
	my $parser = OuterStruct.new;
	$parser.count = 0;
	$parser.after = 4;

	my $res = $parser.build;
	is $res, Buf.new(0, 4);
};

subtest 'basic build (count = 1)', {
	my $parser = OuterStruct.new;
	$parser.items.push(InnerStruct.new);

	$parser.count = 1;
	$parser.items[0].a = 2;
	$parser.items[0].b = 3;
	$parser.after = 4;

	my $res = $parser.build;
	is $res, Buf.new(1, 2, 3, 4);
};

subtest 'basic build (count = 2)', {
	my $parser = OuterStruct.new;
	$parser.items.push(InnerStruct.new);
	$parser.items.push(InnerStruct.new);

	$parser.count = 2;
	$parser.items[0].a = 2;
	$parser.items[0].b = 3;
	$parser.items[1].a = 4;
	$parser.items[1].b = 5;
	$parser.after = 6;

	my $res = $parser.build;
	is $res, Buf.new(2, 2 .. 6);
};

done-testing;
