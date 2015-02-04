#!/usr/bin/env perl6
use Test;
plan 2;

class Pandapack::Plugins::Test {
#prebuild
  method bundle {
    ok 1, 'bundle called';
  }

#postbuild
  method postbundle {
    ok 1, 'postbundle called';
  }
}
