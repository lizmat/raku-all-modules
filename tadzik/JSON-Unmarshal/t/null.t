#!/usr/bin/env perl6

use v6.*;

use Test;
use JSON::Unmarshal;

my Str $json = '{ "attr" : null }';

my @tests = %( "class" => class  { has Int $.attr; }, description => "Int attribute" ),
            %( "class" => class  { has Num $.attr; }, description => "Num attribute" ),
            %( "class" => class  { has Rat $.attr; }, description => "Rat attribute" ),
            %( "class" => class  { has Str $.attr; }, description => "Str attribute" ),;

for @tests -> $test {
    my $obj;
    lives-ok { $obj = unmarshal($json, $test<class> ) }, $test<description>;
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
