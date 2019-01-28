#! /usr/bin/env false

use v6.c;

unit module Factorial;

#factorial 
sub postfix:<!>(UInt $operand)
		is tighter(&infix:<**>)
	   	is export {
	[*] 1..$operand;
}

#
# vim: ft=perl6 noet
#
#
