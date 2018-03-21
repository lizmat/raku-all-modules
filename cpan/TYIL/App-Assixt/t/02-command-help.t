#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Test;
use Test;

plan 3;

my $assixt = $*CWD;

ok run-bin($assixt), "USAGE is shown when no commands are passed";
ok run-bin($assixt, "help"), "Help command does not fail";
ok run-bin($assixt, "--help"), "--help option does not fail";

# vim: ft=perl6 noet
