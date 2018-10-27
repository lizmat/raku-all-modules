use v6;
use lib 'lib';

use Test;

use Binary::Structured;

class TwoPass is Binary::Structured {
	has uint8 $.a is rw is rewritten = -1;
	has uint8 $.b is rw;
	has uint8 $.c is rw;
	has Buf $.final is written(method {
		$.a = $.c;
		self.rewrite-attribute('$!a');
		Buf.new;
	}) is read(method {Buf.new});
}

subtest 'build basic', {
	my $parser = TwoPass.new;
	$parser.b = 2;
	$parser.c = 3;
	my $buf = $parser.build;

	is $buf.list, [3, 2, 3];
};


done-testing;
