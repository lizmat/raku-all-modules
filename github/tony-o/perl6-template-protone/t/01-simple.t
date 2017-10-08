#!/usr/bin/env perl6

use Test;
use Template::Protone;
plan 1;

my Template::Protone $bff .= new;

my $r = $bff.render(:template<t/templates/template2.protone>, :data(HELLO => 'WORLD!'));

ok $r eq "hello world\n\n\$data<HELLO> = 'WORLD!'\n\n0\n1\n2\n3\n4\n";
