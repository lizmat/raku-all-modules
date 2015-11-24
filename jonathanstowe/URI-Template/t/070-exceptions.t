#!perl6

use v6;
use lib 'lib';

use Test;

use URI::Template;

my $t;

$t = URI::Template.new();

throws-like { $t.process(foo => 1, bar => 2) }, X::NoTemplate, "throws 'X::NoTemplate' without a defined template";

$t = URI::Template.new(template => '{?foo/boo');

throws-like { $t.process(foo => 1, bar => 2) }, X::InvalidTemplate, "throws 'X::InvalidTemplate' with a broken template";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
