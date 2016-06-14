#!/usr/bin/env perl6

use v6.c;
use lib '../lib';

use Config::TOML::Refine;

my Config::TOML::Refine $c .= new(:config-name<ex1-pod.toml>);

say "\n", $c.refine(<options plugin1 test>).perl;

say "\n", $c.refine-filter(<options plugin1 test>).perl;

say "\n", $c.refine-filter-str(<options plugin1 deploy>).perl;

say "\n", $c.refine-filter-str(<options plugin2 deploy>).perl;


