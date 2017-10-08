use v6;

use Test;
use lib 'lib';

use Text::Caesar;

plan 1;

my Str $message = "I'm a secret message.";
is encrypt(3, $message), "L'P D VHFUHW PHVVDJH.";
