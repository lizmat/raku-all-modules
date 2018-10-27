unit module StrictNamedArguments;
use v6;

# First we need some exception to throw. Perl 6 kindly creates a
# constructor for us that deals with filling all attributes with
# values, so we can provide details when we throw the exception.

class X::Parameter::ExtraNamed is Exception {
	has $.extra-parameters;
	has $.classname;
	has $.method-name;
	method message () {
        state ($r, $c, $g);
        once { 
            ($r, $c, $g) = '','','';
            try { ($r, $c, $g ) = Rakudo::Internals.error-rcgye; } # red, clear, green, yelow, eject
        }
		
        "The method $g$.method-name$c of $g$.classname$c received " ~ 
		"an invalid named parameter(s): $r$.extra-parameters$c";
	}
}

# We modify methods with a trait. A trait is a modification of the
# Perl 6 grammar and a subroutine. The thing it operates on is
# stored in the first positional. In our case that's a method.

multi sub trait_mod:<is>(Method $m, :$strict!) is export {
	my @named-params;
	my $invocant-type;
	my $method-name = $m.name;

	# The signature of a method can provide us with a list of parameters.
	for $m.signature.params -> $p {
		$invocant-type = $p.type if $p.invocant; #classname
		# We are only interested in named arguments.
		next unless $p.named;
		# Each named arguments startes with a sigil ($ in this case).
		# we strip it from the method name and store the rest for safekeeping.
		@named-params.push: $p.name.substr(1);
	}

	# After we got all the information we need, we come to the business
	# end of our trait. We wrap the method in a new method.
	# We only want to peek into it's argument list so we take a capture.
	# Conveniently a capture provided us with a method to get a list of
	# all named arguments it contains.
	$m.wrap: method (|args) {
		# We first check with the subset operator C<(<=)> if there are any
		# named arguments we don't like and if so, we use the set difference
		# operator C<(-)> to name only those. The exception we defined earlier
		# takes care of the rest.
		X::Parameter::ExtraNamed.new(
			method-name      => $method-name,
		    classname        => $invocant-type.perl,
		    extra-parameters => args.hash.keys (-) @named-params
		).throw unless args.hash.keys (<=) @named-params;
		
		# If all named arguments are fine, we can call the wrapped method and
		# forward all arguments kept in the capture.
		callwith(self, |args);
	}
}

# vim: ft=perl6 expandtab sw=4
