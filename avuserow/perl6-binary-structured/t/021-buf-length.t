use v6;
use lib 'lib';

use Test;

use Binary::Structured;

class PascalString is Binary::Structured {
	has uint8 $.length is written(method {$.string.bytes});
	has Buf $.string is read(method {self.pull($.length)}) is rw;
}

subtest 'parse zero length', {
	my $buf = Buf.new: 0;
	my $parser = PascalString.new;
	$parser.parse($buf);
	is $parser.length, 0, 'length';
	is $parser.string.bytes, 0, 'bytes read';
};

subtest 'parse correct length', {
	my $str = 'hello world';
	my $buf = Buf.new: $str.chars, $str.ords;
	my $parser = PascalString.new;
	$parser.parse($buf);

	isnt $parser.length, 0, 'non-zero length read';
	is $parser.length, $str.chars, 'length read';
	isnt $parser.string.bytes, 0, 'non-zero bytes read';
	is $parser.string.bytes, $str.chars, 'correct bytes count read';
	is $parser.string.list, $str.ords, 'bytes are correct';
};

subtest 'parse trailing garbage', {
	my $str = 'hello world';
	my $length = 5;
	my $buf = Buf.new: $length, $str.ords;
	my $parser = PascalString.new;
	$parser.parse($buf);

	isnt $parser.length, 0, 'non-zero length read';
	is $parser.length, $length, 'length read';
	isnt $parser.string.bytes, 0, 'non-zero bytes read';
	is $parser.string.bytes, $length, 'correct bytes count read';
	is $parser.string.list, $str.ords[^$length], 'bytes are correct';
};

subtest 'build zero length', {
	my $parser = PascalString.new;
	$parser.string = Buf.new;
	my $buf = $parser.build;
	is $buf, Buf.new(0);
};

subtest 'build regular', {
	my $parser = PascalString.new;
	my $buf = Buf.new: "hello world".ords;
	$parser.string = $buf;
	my $res = $parser.build;
	is $res, Buf.new($buf.bytes, $buf.list);
};

done-testing;
