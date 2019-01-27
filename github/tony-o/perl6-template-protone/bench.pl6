#!/usr/bin/env perl6

use lib 'lib';
use Bench;
use Template::Protone; 

sub MAIN(Int :$iterations? = 1000) {
  my Bench $bench .= new;
  my Template::Protone $pro .= new;

  $bench.timethese($iterations, { 
    parsing => sub { $pro.parse(template => 't/templates/template.protone', name => 'test'); },
    render  => sub { $pro.render(name => 'test',); },
  });
}
