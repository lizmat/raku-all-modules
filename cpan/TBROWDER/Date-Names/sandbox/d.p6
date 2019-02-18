#!/usr/bin/env perl6

use lib <./lib>;
use T::F;


my $foo = 'T::F::en::dow';
#my $f = $::("OUR::$foo"); # DOES NOT WORK
my $f = $::($foo); # DOES WORK!!
say $f.gist;
say $foo.gist;
for $f.kv -> $i, $v {
    say "$i: $v";
}

