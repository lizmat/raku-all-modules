#! /Users/damian/bin/rakudo'
use v6;

use IO::Prompter;

while prompt('Args:', :args) -> $input {
    say "Got [$input]";
    say @*ARGS.perl;
}


