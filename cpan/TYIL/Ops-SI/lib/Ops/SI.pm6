#! /usr/bin/env false

use v6.c;

unit module Ops::SI;

#| "y" postfix for the yokto SI prefix
multi sub postfix:<y> (Real $a) is export { $a × 10¯²⁴ }

#| "z" postfix for the zepto SI prefix
multi sub postfix:<z> (Real $a) is export { $a × 10¯²¹ }

#| "a" postfix for the atto SI prefix
multi sub postfix:<a> (Real $a) is export { $a × 10¯¹⁸ }

#| "f" postfix for the femto SI prefix
multi sub postfix:<f> (Real $a) is export { $a × 10¯¹⁵ }

#| "p" postfix for the pico SI prefix
multi sub postfix:<p> (Real $a) is export { $a × 10¯¹² }

#| "n" postfix for the nano SI prefix
multi sub postfix:<n> (Real $a) is export { $a × 10¯⁹ }

#| "µ" postfix for the mikro SI prefix
multi sub postfix:<µ> (Real $a) is export { $a × 10¯⁶ }

#| "m" postfix for the milli SI prefix
multi sub postfix:<m> (Real $a) is export { $a × 10¯³ }

#| "c" postfix for the centy SI prefix
multi sub postfix:<c> (Real $a) is export { $a × 10¯² }

#| "d" postfix for the decy SI prefix
multi sub postfix:<d> (Real $a) is export { $a × 10¯¹ }

#| "da" postfix for the deca SI prefix
multi sub postfix:<da> (Real $a) is export { $a × 10¹ }

#| "h" postfix for the hecto SI prefix
multi sub postfix:<h> (Real $a) is export { $a × 10² }

#| "k" postfix for the kilo SI prefix
multi sub postfix:<k> (Real $a) is export { $a × 10³ }

#| "M" postfix for the mega SI prefix
multi sub postfix:<M> (Real $a) is export { $a × 10⁶ }

#| "G" postfix for the giga SI prefix
multi sub postfix:<G> (Real $a) is export { $a × 10⁹ }

#| "T" postfix for the tera SI prefix
multi sub postfix:<T> (Real $a) is export { $a × 10¹² }

#| "P" postfix for the peta SI prefix
multi sub postfix:<P> (Real $a) is export { $a × 10¹⁵ }

#| "E" postfix for the eksa SI prefix
multi sub postfix:<E> (Real $a) is export { $a × 10¹⁸ }

#| "Z" postfix for the zetta SI prefix
multi sub postfix:<Z> (Real $a) is export { $a × 10²¹ }

#| "Y" postfix for the yotta SI prefix
multi sub postfix:<Y> (Real $a) is export { $a × 10²⁴ }

# vim: ft=perl6 noet
