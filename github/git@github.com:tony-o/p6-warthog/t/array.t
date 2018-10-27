#!/usr/bin/env perl6

use JSON::Fast;
use Test;
use lib 'lib';
use System::Query;

plan 4;
my $json-str = 't/data/array.json'.IO.slurp;
my $options = system-collapse( from-json( $json-str ) );

ok $options<options>.elems == 3;
ok $options<options>[0]<value> eq 'option one';
ok $options<options>[1] eq 'option two';
ok $options<options>[2] eq 'option three';
