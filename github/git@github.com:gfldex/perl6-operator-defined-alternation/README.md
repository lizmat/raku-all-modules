# Operator::defined-alternation
[![Build Status](https://travis-ci.org/gfldex/perl6-operator-defined-alternation.svg?branch=master)](https://travis-ci.org/gfldex/perl6-operator-defined-alternation)

Perl 6 provides control statements and operators to test for definedness instead of trueness, to provide ease of typing and a clear statement of intend from the programmer. Sadly there is currently no way to define your own ternary operators with Rakudo. However, we can emulate operators with 3 arguments with a chain of 2 infix operators, as long as we provide a type for the 2nd infix to handle dispatch properly.

## Usage:
```
use v6;
use Operator::defined-alternation;

my $falsish = 2 but False;
say $falsish ?// 'defined' !! 'undefined';
# OUTPUT: defined
# What is equivalent to:
say $falsish.defined ?? 'defined' !! 'undefined'; 
# OUTPUT: defined
# But opposed to:
say $falsish ?? 'true' !! 'false'; 
# OUTPUT: false 
```

## License

(c) Wenzel P. P. Peppmeyer, Released under Artistic License 2.0.
