use v6;
use lib 'lib', 't/lib';

use Test;

use Binary::Structured;

class CString is Binary::Structured {
	has Buf $.string is read(method {
		# TODO: read more efficiently
		my $c = Buf.new;
		$c ~= self.pull(1) while self.peek-one != 0;
		return $c;
	}) is rw;

	has StaticData $.terminator = Buf.new: 0;
}

subtest 'parse zero length', {
	my $buf = Buf.new: 0;
	my $parser = CString.new;
	$parser.parse($buf);
	is $parser.string.bytes, 0, 'bytes read';
	is $parser.terminator.list, [0], 'terminator is valid';
};

subtest 'parse correct length', {
	my $str = 'hello world';
	my $buf = Buf.new: $str.ords, 0;
	my $parser = CString.new;
	$parser.parse($buf);
	isnt $parser.string.bytes, 0, 'non-zero bytes read';
	is $parser.string.bytes, $str.chars, 'correct bytes count read';
	is $parser.string.list, $str.ords, 'bytes are correct';
	is $parser.terminator.list, [0], 'terminator is valid';
};

subtest 'parse trailing garbage', {
	my $str = "hello\0world";
	my $length = 5;
	my $buf = Buf.new: $str.ords;
	my $parser = CString.new;
	$parser.parse($buf);

	isnt $parser.string.bytes, 0, 'non-zero bytes read';
	is $parser.string.bytes, $length, 'correct bytes count read';
	is $parser.string.list, $str.ords[^$length], 'bytes are correct';
};

subtest 'build zero length', {
	my $parser = CString.new;
	$parser.string = Buf.new;
	my $buf = $parser.build;
	is $buf, Buf.new(0);
};

subtest 'build regular', {
	my $parser = CString.new;
	$parser.string = Buf.new: "hello world".ords;
	my $buf = $parser.build;
	is $buf, Buf.new("hello world".ords, 0);
};

done-testing;
