#!/usr/bin/env perl6

use lib <./lib>;
use T::F;


my $foo = 'T::F::en::dow';
#my $f = $::("OUR::$foo"); # does NOT work
my $f = $::($foo); # DOES WORK!!
say $f.gist;
say $foo.gist;
for $f.kv -> $i, $v {
    say "$i: $v";
}

say "======================";

my $L = "en";
my $D = "dow";
my $bar = "T::F";
$f = $::($bar)::($L)::($D); # DOES WORK!!
$f = $::T::F::($L)::($D); # DOES WORK!!
say $f.gist;
say $foo.gist;
for $f.kv -> $i, $v {
    say "$i: $v";
}



