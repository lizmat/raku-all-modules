use v6.c;
use Test;

=begin pod
=head1 Multi-thread test file
This test file tests if logging from multple threads correctly uses the Singleton instance.
=end pod

plan 2;

class ToLog {
	method foo {
		use Log::Any;
		Log::Any.notice( 'a test from ToLog' );
	}
}

use Log::Any::Adapter;
class MultiThreadTest is Log::Any::Adapter {
	has @.logs;

	method handle( $msg ) {
		push @!logs, $msg;
	}
}

my $mtt = MultiThreadTest.new;

{
	use Log::Any;
	Log::Any.add( $mtt, :formatter( '\c \s: \m' ) );
}

await start {
	ToLog.foo();
}

{
	is $mtt.logs.elems, 1, 'Count logs ok';

	# Check if Category is correctly set to caller class name
	is $mtt.logs[0], 'ToLog notice: a test from ToLog', 'Message log ok';
}
