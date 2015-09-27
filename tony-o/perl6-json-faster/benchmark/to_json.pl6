#!/usr/bin/env perl6

use lib '../lib';
use Bench;

my Bench $bench .=new;
my       $json   = from-json('projects.json'.IO.slurp);


$bench.cmpthese(3, {
  'JSON::Faster' => sub { use JSON::Faster; to-json($json); },
  'JSON::Fast'   => sub { use JSON::Fast;   to-json($json); },
});
