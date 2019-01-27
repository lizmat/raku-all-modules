#! /usr/bin/env perl6

use v6;

use META6;
use Test;

plan 3;

is META6.new(
	:name("Local::Test")
).Str, "Local::Test", "Simple stringification";

is META6.new(
    :name("Local::Test")
    :auth("cpan:TYIL")
    :version(v0.2.4)
).Str, "Local::Test:auth<cpan:TYIL>:version<0.2.4>", "Stringification with auth and version";

is META6.new(
    :name("Some::Other::Test")
    :version(v3.4.5)
    :api(~3)
).Str, "Some::Other::Test:version<3.4.5>:api<3>", "Stringification with version and api";

# vim: expandtab shiftwidth=4 ft=perl6
