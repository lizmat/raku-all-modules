use v6;

use Test;
use lib 'lib';

use Text::Caesar;

plan 1;

my Str $secret = "L'P D VHFUHW PHVVDJH.";
is decrypt(3, $secret), "I'M A SECRET MESSAGE.";
