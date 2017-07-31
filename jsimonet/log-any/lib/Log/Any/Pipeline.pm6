use v6.c;

use Log::Any::Adapter;
use Log::Any::Filter;
use Log::Any::Formatter;

=begin pod
=head1 Log::Any::Pipeline

	A pipeline have to choose which Adapter will handle the log, depending on the
	Log's attributes (category, severity, size of the message, etc.).

	A pipeline is composed of elements, which contains an Adapter and possibly
	a Filter, a Formatter and/or a Proxy.
=end pod

class Log::Any::Pipeline {

	has @!adapters;

	has $.asynchronous = False;
	has Channel $!channel; # Channel used for asynchronicity

	method TWEAK {
		if $!asynchronous {
			$!channel = Channel.new;
			$!channel.Supply.tap( -> %params {
				self!dispatch-synchronous( |%params );
			} );
		}
	}

	method add( Log::Any::Adapter $a, Log::Any::Filter :$filter, Log::Any::Formatter :$formatter, :$continue-on-match = False ) {
		#note "{now} adding adapter $a.WHAT().^name()";
		my %elem = adapter => $a;

		if $filter.defined {
			%elem{'filter'} = $filter;
		}

		if $formatter.defined {
			%elem{'formatter'} = $formatter;
		}

		if $continue-on-match {
			%elem{'continue-on-match'} = True ;
		}

		push @!adapters, %elem;
	}

=begin pod
=head2 get-available-adapters

	This method returns the next element of the pipeline wich is matching
	the filter.
=end pod
	method !get-available-adapters( :$msg, :$severity, :$category, :%extra-fields ) {

		return gather for @!adapters -> %elem {
			# Filter : check if the adapter meets the requirements
			with %elem{'filter'} {
				next unless %elem{'filter'}.filter( :$msg, :$severity, :$category, :%extra-fields );
			}
			# Without filter, it's ok
			take %elem;
		}

	}

	method dispatch( DateTime :$date-time!, :$msg!, :$severity!, :$category!, :%extra-fields ) {
		# note "Dispatching $msg, adapter count : @!adapters.elems(), asynchronicity $!asynchronous.perl() at {now}";

		if $!asynchronous {
			# note "async dispatch";
			$!channel.send( { :$date-time, :$msg, :$severity, :$category } );
		} else {
			# note "sync dispatch";
			return self!dispatch-synchronous( :$date-time, :$msg, :$severity, :$category, :%extra-fields );
		}
	}

	method !dispatch-synchronous( :$date-time!, :$msg! is copy, :$severity!, :$category!, :%extra-fields ) {
		for self!get-available-adapters(  :$msg, :$severity, :$category ) -> %elem {
			if %elem {
				# Escape newlines caracters in message
				$msg ~~ s:g/ \n /\\n/;

				# Formatter
				my $msgToHandle = $msg;
				if %elem{'formatter'} {
					$msgToHandle = %elem{'formatter'}.format( :$date-time, :$msg, :$category, :$severity, :%extra-fields );
				}

				# Proxies

				# Handling
				%elem{'adapter'}.handle( $msgToHandle );
			}
			last unless %elem{'continue-on-match'};
		}
	}

	method will-dispatch( :$severity, :$category, :%extra-fields ) returns Bool {
		return self!get-available-adapters( :$severity, :$category, :%extra-fields ).so;
	}

	# Dump the adapters
	method gist {
		return 'Log::Any::Pipeline.new(adapters => ' ~ @!adapters.gist ~ ')';
	}

}
