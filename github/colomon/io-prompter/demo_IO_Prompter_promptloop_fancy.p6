#! /Users/damian/bin/rakudo'
use v6;

use IO::Prompter;

prompt -> $what's_your_name, Int $age, Bool :wed($married) {

    report($what's_your_name, $age, $married);
}





















sub report ($name, $age, $married) {
    say "    $name (aged $age) is{$married ?? '' !! "n\'t"} married";
}

