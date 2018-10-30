#! /Users/damian/bin/rakudo'
use v6;

use IO::Prompter;

subset Coefficient of Num where 0..1;

prompt -> Num $amount, Coefficient $rate, Int $term, Str $desc where /\S/ {

    say "After $term year(s), $amount will be worth ",
        $amount * (1+$rate)**$term;

    say $desc;
}
