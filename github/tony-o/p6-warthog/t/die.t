#!/usr/bin/env perl6

use JSON::Fast;
use Test;
use lib 'lib';
use System::Query;
use Data::Dump;

plan 1;
my $json-str = 't/data/die.json'.IO.slurp;
dies-ok sub {
  system-collapse( from-json( $json-str ) );
}, 'cannot make a decision';
