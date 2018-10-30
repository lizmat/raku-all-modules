use v6;
use lib 'lib';

use Test;

use Binary::Structured;

class InnerStruct is Binary::Structured {
	has uint8 $.size is rw;
	has Buf $.data is read(method {self.pull($.size)});
}

class OuterStruct is Binary::Structured {
	has uint8 $.count is rw;

	has Array[InnerStruct] $.items is read(method {return $!count});

	has StaticData $.after = Buf.new(0xab);
}

subtest 'parse zero elements', {
	my $buf = Buf.new: 0, 0xab;
	my $parser = OuterStruct.new;
	$parser.parse($buf);

	is $parser.count, 0;
	is $parser.items.elems, 0;
	is $parser.after, Buf.new(0xab);
};

subtest 'parse one element', {
	my $buf = Buf.new: 5, 4, 1, 2, 3, 4, 0xab;
	my $parser = OuterStruct.new;
	$parser.parse($buf);

	is $parser.count, 5;
	is $parser.items.elems, 1;
	is $parser.items[0].size, 4;
	is $parser.items[0].data.bytes, 4;
	is $parser.items[0].data, Buf.new(1, 2, 3, 4);
	is $parser.after, Buf.new(0xab);
};

done-testing;
