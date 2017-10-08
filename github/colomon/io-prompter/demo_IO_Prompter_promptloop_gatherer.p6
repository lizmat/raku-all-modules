#! /Users/damian/bin/rakudo'
use v6;

use IO::Prompter;

my @input = prompt -> $what's_your_name, Int $age, Bool :wed($married) {

     take [$what's_your_name.uc, $age~'ish', $married ?? 'M' !! 'm'];
}

say "\n----------------";
.perl.say for @input;


