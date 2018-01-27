use v6;

unit module Sparrowform;
use JSON::Tiny;
my @tf-resources;

my @hosts = Array.new;

sub tf-resources() is export {
  if (! @tf-resources) {
    my %r = from-json (slurp ".sparrowform/resources.json");
    for %r.keys -> $r {
      push @tf-resources, [ $r, %r{$r} ];
    }
  }
  return @tf-resources;
}

sub save-tf-resources( %data = %()) is export {
  spurt ".sparrowform/resources.json", to-json(%data);
}


