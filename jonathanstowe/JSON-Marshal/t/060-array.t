#!perl6

use v6.c;

use Test;
use JSON::Marshal;
use JSON::Fast;

class TestObject {
    has Str $.string;
}

my @arr = (TestObject.new(string => "one"), TestObject.new(string => "two"));

my $out;

lives-ok { $out = marshal(@arr) }, "marshal an array";

my $test = from-json($out);

is $test[0]<string>, 'one', "got right object in first element";
is $test[1]<string>, 'two', "got right object in second element";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
