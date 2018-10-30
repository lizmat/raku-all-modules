use v6;
use lib 'lib';

use Test;

use Binary::Structured;

class NumericData is Binary::Structured {
	has uint8 $.a is rw;
	has uint16 $.b is rw;
	has uint32 $.c is rw;
	has int8 $.d is rw;
	has int16 $.e is rw;
	has int32 $.f is rw;
}

subtest 'basic parse', {
	my $buf = Buf.new: 1 .. 14;
	my $parser = NumericData.new;
	$parser.parse($buf);

	# NOTE: little endian assumed by default
	is $parser.a, 0x01, 'uint8';
	is $parser.b, 0x0302, 'uint16';
	is $parser.c, 0x07060504, 'uint32';
	is $parser.d, 0x08, 'int8';
	is $parser.e, 0x0a09, 'int16';
	is $parser.f, 0x0e0d0c0b, 'int32';
};

subtest 'parse with unsigned', {
	my $buf = Buf.new: 0xff xx 14;
	my $parser = NumericData.new;
	$parser.parse($buf);

	# NOTE: little endian assumed by default
	todo 'unsigned ints are treated as signed (RT 127210)', 3;
	is $parser.a, 0xff, 'uint8';
	is $parser.b, 0xffff, 'uint16';
	is $parser.c, 0xffffffff, 'uint32';
	is $parser.d, -1, 'int8';
	is $parser.e, -1, 'int16';
	is $parser.f, -1, 'int32';
};

subtest 'basic write', {
	my $buf = Buf.new: 1 .. 14;
	my $parser = NumericData.new;

	# NOTE: little endian assumed by default
	$parser.a = 0x01;
	$parser.b = 0x0302;
	$parser.c = 0x07060504;
	$parser.d = 0x08;
	$parser.e = 0x0a09;
	$parser.f = 0x0e0d0c0b;

	my $res = $parser.build;
	is $res, $buf;
};

subtest 'write with overflow', {
	my $buf = Buf.new: 1 .. 14;
	my $parser = NumericData.new;

	# NOTE: little endian assumed by default
	# Add some extra bits in front to overflow the value
	todo 'unsigned ints are treated as signed (RT 127210)', 3;
	$parser.a = 0xf01;
	$parser.b = 0xf0302;
	$parser.c = 0xf07060504;
	$parser.d = 0xf08;
	$parser.e = 0xf0a09;
	$parser.f = 0xf0e0d0c0b;

	my $res = $parser.build;
	is $res, $buf;
};

done-testing;
