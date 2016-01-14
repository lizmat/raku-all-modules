	use v6;
	use StrictNamedArguments;

	# Just use the trait 'strict' for methods
	class Foo { 	 # your class
	    has $.valid; # attribute, used by .new
	
		# A regular method that expects a named argument:
		# msg => 'some_value'
		# and returns the value in upper case (in this example)
	    method shout(:$msg) is strict { $msg.uc.say; self }
	
		# The Perl6 constructor is a regular method and can also
		# me made strict if you provide the method strictly.
		# The syntax of named parameters is a hash to be blessed.
	    method new(:$valid) is strict { self.bless(valid => $valid) }
	}

	Foo.new(:not-valid).shout(:not-valid);

	CATCH {
		when X::Parameter::ExtraNamed {
			note Backtrace.new.full;
			note .gist;
		} 
	}
