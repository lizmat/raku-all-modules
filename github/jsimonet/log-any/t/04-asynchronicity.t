use v6.c;
use Test;

=begin pod
=head1 Asynchronicity test file
=para This test file tests the asynchronicity.
=end pod

plan 5;

use Log::Any::Adapter;

class AdapterDebug is Log::Any::Adapter {
	has @.logs;
	method handle( $msg ) {
		sleep 0.2;
		push @!logs, $msg;
	}
}

use Log::Any;

my $pipeline = Log::Any::Pipeline.new( :asynchronous );
dies-ok
	{ Log::Any.add( $pipeline ) },
	'Cannot add the pipeline because default one already exists';
lives-ok
	{ Log::Any.add( $pipeline, :overwrite ) },
	'Add the "default" pipeline with :overwrite because it already exists';
lives-ok
	{ Log::Any.add( $pipeline, :pipeline('async') ) },
	'Add the new "async" pipeline.';

my $a = AdapterDebug.new;
Log::Any.add( $a, :pipeline('async') );
Log::Any.log( :msg('msg'), :pipeline('async'), :severity('info') );
is $a.logs, [], 'Adapter did not logged yet.';
sleep 0.4;
is $a.logs, ['msg'], 'Adapter logged the message.';
