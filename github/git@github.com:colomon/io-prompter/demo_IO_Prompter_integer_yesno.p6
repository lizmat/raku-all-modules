#! /Users/damian/bin/rakudo'
use v6;

use IO::Prompter;

loop {
    my $name    = prompt("Name:")            // last;
    my $age     = prompt("Age:", :integer, :must({'be positive' => {$_ > 0}}) )
                                      // last;
    my $married = prompt("Married?", :yesno) // last;

    report($name, $age, $married);
}





















sub report ($name, $age, $married) {
    say "    $name (aged $age) is{$married ?? '' !! "n\'t"} married";
}

