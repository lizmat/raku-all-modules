use v6;
use Test;
use FastCGI::NativeCall;
use FastCGI::NativeCall::PSGI;
use MONKEY-TYPING;

plan 2;

augment class FastCGI::NativeCall::PSGI {
	method get-app {
		return $!app;
	}
}

my $sock = FastCGI::NativeCall::OpenSocket('01-test.sock', 5);
my $psgi = FastCGI::NativeCall::PSGI.new(FastCGI::NativeCall.new($sock));

ok $psgi, 'created object';

sub dispatch-psgi($env) { return 'works' }

$psgi.app(&dispatch-psgi);

is $psgi.get-app()({}), 'works', 'app successfully set';

unlink('01-test.sock');
