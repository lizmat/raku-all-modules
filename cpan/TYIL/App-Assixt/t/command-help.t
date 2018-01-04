#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Commands::Help;
use Test;

multi sub MAIN { 0 }

plan 1;

ok MAIN("help"), "Help command does not fail";

# vim: ft=perl6 noet
