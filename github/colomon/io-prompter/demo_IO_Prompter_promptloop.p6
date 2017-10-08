#! /Users/damian/bin/rakudo'
use v6;

use IO::Prompter;

prompt -> $name, Int $age, Bool $married {

    report($name, $age, $married);
}





















sub report ($name, $age, $married) {
    say "    $name (aged $age) is{$married ?? '' !! "n\'t"} married";
}


