#!/usr/bin/env perl6

use lib '../lib';
use Bench;

my Bench $bench .=new;
my       $json   = 'projects.json'.IO.slurp;


$bench.cmpthese(3, {
  'built-in'     => sub { from-json($json); },
  'JSON::Faster' => sub { use JSON::Faster; from-json($json); },
});
