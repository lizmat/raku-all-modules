use v6.c;

use Test;

plan 3;

use Log::Any;
use Log::Any::Adapter;


class AdapterDebug is Log::Any::Adapter {
	has @.logs;

	method handle( $msg ) {
		push @!logs, $msg;
	}
}

my $a = AdapterDebug.new;
# Formatter test
# test-2 pipeline
$a.logs = [];
Log::Any.add( $a, :pipeline( 'test-2' ), :formatter( '\d \s \c \m' ) );

my $before-log = DateTime.new( now );
Log::Any.log( :pipeline( 'test-2' ), :msg('test-2'), :severity( 'trace' ), :category( 'test-category' ) );
my $after-log = DateTime.new( now );

with $a.logs[*-1] {
	like $_, /^ (<-[\s]>+) \s 'trace test-category test-2' $/, 'Log with formatter in test-2 pipeline';
	# Check if log dateTime is after $before-log, and before $after-log
	with $_ ~~ /^ (<-[\s]>+)/ {
		my $log-dateTime = DateTime.new( $_.Str );
		if $before-log <= $log-dateTime <= $after-log {
			pass "Log DateTime is in the interval";
		} else {
			flunk "Log DateTime is not in the interval";
		}
	} else {
		flunk "Failed to extract dateTime from log message";
	}
} else {
	flunk 'Log with formatter in test-2 pipeline';
}

# Test for extra fields
$a.logs = [];
Log::Any.add( $a, :pipeline('ef'), :formatter('\e{key1} \e{key2} \e{nonexistant}') );
Log::Any.info( :pipeline('ef'), 'ef', :extra-fields( { :key1('val1'), :key2('val2'), :key3('unused') } ) );

is $a.logs[*-1], 'val1 val2 \e{nonexistant}', 'Extra fields';
