# StrictNamedArguments
[![Build Status](https://travis-ci.org/nxadm/StrictNamedArguments.svg?branch=master)](https://travis-ci.org/nxadm/StrictNamedArguments)

While Perl 6 is strict on types when one is specified in the parameter
definition, the default behaviour for values for unknown named parameters
in methods (and constructors) is just to ignore them.
With this module, you can let Perl 6 throw an exception when invalid 
named parameters are supplied. Let Perl6 watch yours fingers for these typos.

See https://perl6advent.wordpress.com/2015/12/13/a-new-trait-for-old-methods/

Usage:
```
use v6;
use StrictNamedArguments;

# Just use the trait 'strict' for methods
class Foo { 	 # your class
    has $.valid; # attribute, used by .new

	# A regular method that expects a named argument:
	# msg => 'some_value'
	# and returns the value in upper case (in this example)
    method shout(:$msg) is strict { $msg.uc }

	# The Perl6 constructor is a regular method and can also
	# me made strict if you provide the method strictly.
	# The syntax of named parameters is a hash to be blessed.
    method new(:$valid) is strict { self.bless(valid => $valid) }
}
```

Example output for $foo.shout( msg_ => 'some_value' ) method call:
```
The method shout of Foo received an invalid named parameter(s): msg_
  in method <anon> at /home/claudio/Code/StrictNamedArguments/lib/StrictNamedArguments.pm line 47
  in any enter at gen/moar/m-Metamodel.nqp line 3927
  in block <unit> at t/strict2.t line 19
```
