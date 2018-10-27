#!perl6

use v6;
use lib 'lib';

use Test;

use Audio::Silan;

my $obj;

lives-ok { $obj = Audio::Silan.new }, "default constructor";

lives-ok { $obj = Audio::Silan.new(hold-off => 5, threshold => 0.0001) }, "constructor with parameters";

is $obj.hold-off, 5, "hold-off is right";
is $obj.threshold, 0.0001, "threshold is right";




done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
