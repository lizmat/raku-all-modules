use v6;
use lib 'lib';

use Test;

use Binary::Structured;

class BasicPosition is Binary::Structured {
	has StreamPosition $.position1;
	has uint8 $.size is rw;
	has Buf $.data is read(method {self.pull($.size)}) is rw;
	has StreamPosition $.position2;

	# HACK: emit the positions when writing, ignore when reading
	# This makes this class non-round-trip capable!
	has Buf $.positions is read(method {Buf.new}) is written(method {Buf.new($.position1, $.position2)});
}

subtest 'parse basic (short)', {
	my $buf = Buf.new: 4, 1, 2, 3, 4;
	my $parser = BasicPosition.new;
	$parser.parse($buf);

	is $parser.position1, 0;
	is $parser.size, 4;
	is $parser.data.bytes, 4;
	is $parser.data, Buf.new(1, 2, 3, 4);
	is $parser.position2, $buf.bytes;
	is $parser.position2, $parser.pos;
};

subtest 'parse basic (long)', {
	my $buf = Buf.new: 10, ^10;
	my $parser = BasicPosition.new;
	$parser.parse($buf);

	is $parser.position1, 0;
	is $parser.size, 10;
	is $parser.data.bytes, 10;
	is $parser.data, Buf.new(^10);
	is $parser.position2, $buf.bytes;
	is $parser.position2, $parser.pos;
};

subtest 'build basic (short)', {
	my $parser = BasicPosition.new;
	$parser.data = Buf.new: 2, 4, 6;
	$parser.size = $parser.data.bytes;
	is $parser.build.list, (3, 2, 4, 6, 0, 4);
};

subtest 'build basic (long)', {
	my $parser = BasicPosition.new;
	$parser.data = Buf.new: 2, 4, 6, ^10;
	$parser.size = $parser.data.bytes;
	is $parser.build.list, ($parser.data.bytes, 2, 4, 6, ^10, 0, 1 + $parser.data.bytes);
};

done-testing;
