#!/usr/bin/env perl6
use Pluggable;

class Pandapack does Pluggable {
  method build {
    my %instances;
    for @.plugins -> $plugin {
      %instances{$plugin} = ::($plugin).new;
      %instances{$plugin}.bundle if %instances{$plugin}.^can('bundle');
    }
    for @.plugins -> $plugin {
      %instances{$plugin} = ::($plugin).new if !defined %instances{$plugin};
      %instances{$plugin}.postbundle if %instances{$plugin}.^can('postbundle');
    }
  }
};
